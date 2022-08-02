<?php

declare(strict_types=1);

namespace App;

use GuzzleHttp\Client;
use PHPUnit\Framework\TestCase;
use SmartAssert\YamlFile\Collection\ArrayCollection;
use SmartAssert\YamlFile\Collection\Serializer as YamlFileCollectionSerializer;
use SmartAssert\YamlFile\FileHashes\Serializer as FileHashesSerializer;
use SmartAssert\YamlFile\YamlFile;
use Symfony\Component\Yaml\Dumper as YamlDumper;

class ApplicationTest extends TestCase
{
    private const JOB_LABEL = 'job-label-content';
    private const JOB_MAXIMUM_DURATION_IN_SECONDS = 600;

    private const EVENT_DELIVERY_URL = 'http://callback-receiver:8080/';

    private static Client $httpClient;
    private static string $fixturePath;
    private static YamlFileCollectionSerializer $yamlFileCollectionSerializer;

    public static function setUpBeforeClass(): void
    {
        parent::setUpBeforeClass();

        self::$httpClient = new Client([
            'verify' => false,
        ]);
        self::$fixturePath = (string) realpath(getcwd() . '/../fixtures');

        self::$yamlFileCollectionSerializer = new YamlFileCollectionSerializer(
            new FileHashesSerializer(
                new YamlDumper()
            )
        );
    }

    public function testCreateJob(): void
    {
        $createJobResponse = self::$httpClient->post('https://localhost/job', [
            'form_params' => [
                'label' => self::JOB_LABEL,
                'event_delivery_url' => self::EVENT_DELIVERY_URL,
                'maximum_duration_in_seconds' => self::JOB_MAXIMUM_DURATION_IN_SECONDS,
                'source' => $this->createJobSource(
                    ['test.yml'],
                    ['test.yml'],
                    [
                        'test.yml' => [
                            '{{ BROWSER }}' => 'chrome',
                        ],
                    ]
                ),
            ],
        ]);
        self::assertSame(200, $createJobResponse->getStatusCode());
        self::assertSame('application/json', $createJobResponse->getHeaderLine('content-type'));

        $this->assertJobStatus([
            'label' => self::JOB_LABEL,
            'event_delivery_url' => self::EVENT_DELIVERY_URL,
            'maximum_duration_in_seconds' => self::JOB_MAXIMUM_DURATION_IN_SECONDS,
            'sources' => [
                'test.yml',
            ],
            'tests' => [],
        ]);

        $this->assertApplicationState([
            'compilation_states' => ['awaiting', 'running', 'complete'],
            'execution_states' => ['awaiting', 'running'],
            'event_delivery_states' => ['awaiting', 'running', 'complete'],
        ]);
    }

    /**
     * @depends testCreateJob
     */
    public function testWaitForApplicationComplete(): void
    {
        $duration = 0;
        $interval = 1;
        $timeout = 60;
        $isComplete = false;

        while ($duration < $timeout && false === $isComplete) {
            $applicationState = $this->getApplicationState();

            $isComplete =
                'complete' === $applicationState['compilation'] &&
                'complete' === $applicationState['execution'] &&
                'complete' === $applicationState['event_delivery'];

            $duration = $duration + $interval;

            sleep($interval);
        }

        self::assertTrue($isComplete);
    }

    /**
     * @return array<mixed>
     */
    private function getApplicationState(): array
    {
        return $this->getJsonResponseAsArray('/application_state');
    }

    /**
     * @return array<mixed>
     */
    private function getJsonResponseAsArray(string $path): array
    {
        $response = self::$httpClient->get('https://localhost' . $path);
        self::assertSame(200, $response->getStatusCode());;

        $data = json_decode($response->getBody()->getContents(), true);

        return is_array($data) ? $data : [];
    }

    /**
     * @param array<mixed> $expected
     */
    private function assertJobStatus(array $expected): void
    {
        $job = $this->getJsonResponseAsArray('/job');

        self::assertSame($expected['label'], $job['label']);
        self::assertSame($expected['event_delivery_url'], $job['event_delivery_url']);
        self::assertSame($expected['maximum_duration_in_seconds'], $job['maximum_duration_in_seconds']);
        self::assertSame($expected['sources'], $job['sources']);
        self::assertSame($job['tests'], $expected['tests']);
    }

    /**
     * @param array<mixed> $expected
     */
    private function assertApplicationState(array $expected): void
    {
        $applicationState = $this->getApplicationState();

        self::assertContains(
            $applicationState['compilation'],
            $expected['compilation_states'],
            sprintf(
                'Compilation state "%s" not in expected states "%s"',
                $applicationState['compilation'],
                implode(', ', $expected['compilation_states'])
            )
        );
        self::assertContains(
            $applicationState['execution'],
            $expected['execution_states'],
            sprintf(
                'Execution state "%s" not in expected states "%s"',
                $applicationState['execution'],
                implode(', ', $expected['execution_states'])
            )
        );
        self::assertContains(
            $applicationState['event_delivery'],
            $expected['event_delivery_states'],
            sprintf(
                'Event delivery state "%s" not in expected states "%s"',
                $applicationState['event_delivery'],
                implode(', ', $expected['event_delivery_states'])
            )
        );
    }

    /**
     * @param string[] $manifestPaths
     * @param string[] $sourcePaths
     * @param array<string, array<string, string>> $sourceContentReplacements
     */
    private function createJobSource(
        array $manifestPaths,
        array $sourcePaths,
        array $sourceContentReplacements = []
    ): string {
        $yamlFiles = [
            YamlFile::create('manifest.yaml', $this->createManifestContent($manifestPaths))
        ];

        foreach ($sourcePaths as $sourcePath) {
            $content = trim((string) file_get_contents(self::$fixturePath . '/basil/' . $sourcePath));

            $replacements = $sourceContentReplacements[$sourcePath] ?? null;
            if (is_array($replacements)) {
                foreach ($replacements as $search => $replace) {
                    $content = str_replace($search, $replace, $content);
                }
            }

            $yamlFiles[] = YamlFile::create($sourcePath, $content);
        }

        $yamlFileCollection = new ArrayCollection($yamlFiles);

        return self::$yamlFileCollectionSerializer->serialize($yamlFileCollection);
    }

    /**
     * @param string[] $manifestPaths
     */
    private function createManifestContent(array $manifestPaths): string
    {
        $lines = [];
        foreach ($manifestPaths as $path) {
            $lines[] = '- ' . $path;
        }

        return implode("\n", $lines);
    }
}
