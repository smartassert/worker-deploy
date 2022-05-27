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
            'compilation_states' => ['awaiting', 'running', 'complete'],
            'execution_states' => ['awaiting', 'running'],
            'event_delivery_states' => ['awaiting', 'running', 'complete'],
            'tests' => [],
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
            $job = $this->getJobStatus();

            $isComplete =
                'complete' === $job['compilation_state'] &&
                'complete' === $job['execution_state'] &&
                'complete' === $job['event_delivery_state'];

            $duration = $duration + $interval;

            sleep($interval);
        }

        self::assertTrue($isComplete);
    }

    /**
     * @return array<mixed>
     */
    private function getJobStatus(): array
    {
        $response = self::$httpClient->get('https://localhost/job');
        self::assertSame(200, $response->getStatusCode());

        $data = json_decode($response->getBody()->getContents(), true);

        return is_array($data) ? $data : [];
    }

    /**
     * @param array<mixed> $expectedJobData
     */
    private function assertJobStatus(array $expectedJobData): void
    {
        $job = $this->getJobStatus();

        self::assertSame($expectedJobData['label'], $job['label']);
        self::assertSame($expectedJobData['event_delivery_url'], $job['event_delivery_url']);
        self::assertSame($expectedJobData['maximum_duration_in_seconds'], $job['maximum_duration_in_seconds']);
        self::assertSame($expectedJobData['sources'], $job['sources']);
        self::assertContains(
            $job['compilation_state'],
            $expectedJobData['compilation_states'],
            sprintf(
                'Compilation state "%s" not in expected states "%s"',
                $job['compilation_state'],
                implode(', ', $expectedJobData['compilation_states'])
            )
        );
        self::assertContains(
            $job['execution_state'],
            $expectedJobData['execution_states'],
            sprintf(
                'Execution state "%s" not in expected states "%s"',
                $job['execution_state'],
                implode(', ', $expectedJobData['execution_states'])
            )
        );
        self::assertContains(
            $job['event_delivery_state'],
            $expectedJobData['event_delivery_states'],
            sprintf(
                'Event delivery state "%s" not in expected states "%s"',
                $job['event_delivery_state'],
                implode(', ', $expectedJobData['event_delivery_states'])
            )
        );
        self::assertSame($job['tests'], $expectedJobData['tests']);
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
