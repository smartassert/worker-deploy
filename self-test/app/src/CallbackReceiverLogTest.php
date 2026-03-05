<?php

declare(strict_types=1);

namespace App;

use PHPUnit\Framework\TestCase;

class CallbackReceiverLogTest extends TestCase
{
    private const JOB_LABEL = 'job-label-content';

    /**
     * @var array<array<mixed>>
     */
    private static array $logSections = [];

    public static function setUpBeforeClass(): void
    {
        parent::setUpBeforeClass();

        self::$logSections = self::extractLogSections((string) stream_get_contents(STDIN));
    }

    public function testLogSize(): void
    {
        self::assertCount(11, self::$logSections);
    }

    /**
     * @dataProvider logBodyDataProvider
     *
     * @param array<mixed> $expectedLogSectionBodies
     */
    public function testLogBody(array $expectedLogSectionBodies): void
    {
        $logSectionBodyDataCollection = [];
        foreach (self::$logSections as $logSection) {
            $logSectionBodyDataCollection[] = $this->decodeLogSectionBody($logSection);
        }

//        ini_set('xdebug.var_display_max_depth', '-1');
//        ini_set('xdebug.var_display_max_data', '-1');
//
//        echo "=================================================================================================";
//        echo json_encode($expectedLogSectionBodies, JSON_PRETTY_PRINT);
//        echo "=================================================================================================";
//        echo json_encode($logSectionBodyDataCollection, JSON_PRETTY_PRINT);
//        echo "=================================================================================================";

//        foreach ($logSectionBodyDataCollection as $key => $value) {
//            echo "\n\n\n\n\n";
//            echo $key . "=================================================================================================";
//            echo json_encode($value, JSON_PRETTY_PRINT);
//            echo $key ."=================================================================================================";
//            echo "\n\n\n\n\n";
//        }

        self::assertCount(count(self::$logSections), $expectedLogSectionBodies);

        foreach ($expectedLogSectionBodies as $expectedLogSection) {
            self::assertContains($expectedLogSection, $logSectionBodyDataCollection);
        }
    }

    /**
     * @return array<mixed>
     */
    public function logBodyDataProvider(): array
    {
        return [
            'default' => [
                'expectedLogSectionBodies' => [
                    [
                        'sequence_number' => 1,
                        'type' => 'job/started',
                        'body' => [
                            'tests' => ['test.yml'],
                        ],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                        'related_references' => [
                            [
                                'label' => 'test.yml',
                                'reference'=> md5(self::JOB_LABEL . 'test.yml'),
                            ],
                        ],
                    ],
                    [
                        'sequence_number' => 2,
                        'type' => 'job/compilation/started',
                        'body' => [],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                    [
                        'sequence_number' => 3,
                        'type' => 'source-compilation/started',
                        'body' => [
                            'source' => 'test.yml',
                        ],
                        'label' => 'test.yml',
                        'reference' => md5(self::JOB_LABEL . 'test.yml'),
                    ],
                    [
                        'sequence_number' => 4,
                        'type' => 'source-compilation/passed',
                        'body' => [
                            'source' => 'test.yml',
                        ],
                        'label' => 'test.yml',
                        'reference' => md5(self::JOB_LABEL . 'test.yml'),
                        'related_references' => [
                            [
                                'label' => 'verify page is open',
                                'reference'=> md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                            ],
                        ],
                    ],
                    [
                        'sequence_number' => 5,
                        'type' => 'job/compilation/ended',
                        'body' => [],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                    [
                        'sequence_number' => 6,
                        'type' => 'job/execution/started',
                        'body' => [],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                    [
                        'sequence_number' => 7,
                        'type' => 'test/started',
                        'body' => [
                            'source' => 'test.yml',
                            'document' => [
                                'type' => 'test',
                                'payload' => [
                                    'path' => 'test.yml',
                                    'config' => [
                                        'browser' => 'chrome',
                                        'url' => 'http://http-fixtures',
                                    ],
                                ],
                            ],
                            'step_names' => [
                                'verify page is open',
                            ],
                        ],
                        'label' => 'test.yml',
                        'reference' => md5(self::JOB_LABEL . 'test.yml'),
                        'related_references' => [
                            [
                                'label' => 'verify page is open',
                                'reference'=> md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                            ],
                        ],
                    ],
                    [
                        'sequence_number' => 8,
                        'type' => 'step/passed',
                        'body' => [
                            'source' => 'test.yml',
                            'document' => [
                                'type' => 'step',
                                'payload' => [
                                    'name' => 'verify page is open',
                                    'status' => 'passed',
                                    'statements' => [
                                        [
                                            'type' => 'assertion',
                                            'source' => '$page.url is "http://http-fixtures/"',
                                            'status' => 'passed',
                                        ],
                                    ],
                                ],
                            ],
                            'step_names' => [
                                'verify page is open',
                            ],
                        ],
                        'label' => 'verify page is open',
                        'reference'=> md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                    ],
                    [
                        'sequence_number' => 9,
                        'type' => 'test/passed',
                        'body' => [
                            'source' => 'test.yml',
                            'document' => [
                                'type' => 'test',
                                'payload' => [
                                    'path' => 'test.yml',
                                    'config' => [
                                        'browser' => 'chrome',
                                        'url' => 'http://http-fixtures',
                                    ],
                                ],
                            ],
                            'step_names' => [
                                'verify page is open',
                            ],
                        ],
                        'label' => 'test.yml',
                        'reference' => md5(self::JOB_LABEL . 'test.yml'),
                        'related_references' => [
                            [
                                'label' => 'verify page is open',
                                'reference'=> md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                            ],
                        ],
                    ],
                    [
                        'sequence_number' => 10,
                        'type' => 'job/execution/completed',
                        'body' => [],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                    [
                        'sequence_number' => 11,
                        'type' => 'job/ended',
                        'body' => [
                            'end_state' => 'complete',
                            'success' => true,
                            'event_count' => 11,
                        ],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                ],
            ],
        ];
    }

    /**
     * @param array<mixed> $logSection
     *
     * @return array<mixed>
     */
    private function decodeLogSectionBody(array $logSection): array
    {
        $bodyContent = $logSection['body'];
        $bodyData = json_decode($bodyContent, true);

        if (!is_array($bodyData)) {
            $bodyData = [];
        }

        return $bodyData;
    }

    /**
     * @return array<array<mixed>>
     */
    private static function extractLogSections(string $raw): array
    {
        $result = [];
        $sections = explode('-----------------', $raw);
        $sections = array_filter($sections);

        foreach ($sections as $section) {
            $sectionJson = self::getJsonFromLogSection($section);
            $sectionData = json_decode($sectionJson, true);

            if (!is_array($sectionData)) {
                $sectionData = [];
            }

            $result[] = $sectionData;
        }

        return $result;
    }

    private static function getJsonFromLogSection(string $section): string
    {
        $lines = explode("\n", trim($section));
        array_pop($lines);

        return implode("\n", $lines);
    }
}
