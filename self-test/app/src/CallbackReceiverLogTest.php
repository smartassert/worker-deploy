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
        self::assertCount(10, self::$logSections);
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
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 1,
                            'type' => 'job/started',
                            'label' => 'job-label-content',
                            'reference' => md5(self::JOB_LABEL),
                            'related_references' => [
                                [
                                    'label' => 'test.yml',
                                    'reference'=> md5(self::JOB_LABEL . 'test.yml'),
                                ],
                            ],
                        ],
                        'body' => [
                            'tests' => [
                                'test.yml',
                            ],
                        ],
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 2,
                            'type' => 'compilation/started',
                            'label' => 'test.yml',
                            'reference' => md5(self::JOB_LABEL . 'test.yml'),
                        ],
                        'body' => [
                            'source' => 'test.yml',
                        ],
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 3,
                            'type' => 'compilation/passed',
                            'label' => 'test.yml',
                            'reference' => md5(self::JOB_LABEL . 'test.yml'),
                            'related_references' => [
                                [
                                    'label' => 'verify page is open',
                                    'reference'=> md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                                ],
                            ],
                        ],
                        'body' => [
                            'source' => 'test.yml',
                        ],
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 4,
                            'type' => 'job/compiled',
                            'label' => self::JOB_LABEL,
                            'reference' => md5(self::JOB_LABEL),
                        ],
                        'body' => [],
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 5,
                            'type' => 'execution/started',
                            'label' => self::JOB_LABEL,
                            'reference' => md5(self::JOB_LABEL),
                        ],
                        'body' => [],
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 6,
                            'type' => 'test/started',
                            'label' => 'test.yml',
                            'reference' => md5(self::JOB_LABEL . 'test.yml'),
                            'related_references' => [
                                [
                                    'label' => 'verify page is open',
                                    'reference'=> md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                                ],
                            ],
                        ],
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
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 7,
                            'type' => 'step/passed',
                            'label' => 'verify page is open',
                            'reference' => md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                        ],
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
                            'name' => 'verify page is open',
                        ],
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 8,
                            'type' => 'test/passed',
                            'label' => 'test.yml',
                            'reference' => md5(self::JOB_LABEL . 'test.yml'),
                            'related_references' => [
                                [
                                    'label' => 'verify page is open',
                                    'reference'=> md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                                ],
                            ],
                        ],
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
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 9,
                            'type' => 'execution/completed',
                            'label' => self::JOB_LABEL,
                            'reference' => md5(self::JOB_LABEL),
                        ],
                        'body' => [],
                    ],
                    [
                        'header' => [
                            'job' => self::JOB_LABEL,
                            'sequence_number' => 10,
                            'type' => 'job/completed',
                            'label' => self::JOB_LABEL,
                            'reference' => md5(self::JOB_LABEL),
                        ],
                        'body' => [],
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
