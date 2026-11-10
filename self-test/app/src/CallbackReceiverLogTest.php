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

    /**
     * @var array<array<mixed>>
     */
    private static array $notifications = [];

    public static function setUpBeforeClass(): void
    {
        parent::setUpBeforeClass();

        self::$logSections = self::extractLogSections((string) stream_get_contents(STDIN));

        $notifications = [];
        foreach (self::$logSections as $logSection) {
            $notifications[] = self::decodeLoggedNotification($logSection);
        }

        self::$notifications = $notifications;
    }

    public function testLogSize(): void
    {
        self::assertCount(17, self::$logSections, self::renderLogAssertionFailureMessage());
    }

    /**
     * @dataProvider notificationsDataProvider
     *
     * @param array<array<mixed>> $notifications
     * @param array<array<mixed>> $expected
     */
    public function testNotifications(array $notifications, array $expected): void
    {
        self::assertCount(
            count($expected),
            $notifications,
            self::renderLogAssertionFailureMessage(),
        );

        foreach ($expected as $expectedLoggedNotification) {
            self::assertContains(
                $expectedLoggedNotification,
                $notifications,
                self::renderLogAssertionFailureMessage(),
            );
        }
    }

    /**
     * @return array<mixed>
     */
    public function notificationsDataProvider(): array
    {
        $applicationAwaitingState = [
            'state' => 'awaiting',
            'meta_state' => [
                'pending' => true,
                'ended' => false,
                'succeeded' => false,
            ],
            'previous_states' => [
                'awaiting',
            ],
        ];

        $applicationCompilingState = [
            'state' => 'compiling',
            'meta_state' => [
                'pending' => false,
                'ended' => false,
                'succeeded' => false,
            ],
            'previous_states' => [
                'awaiting',
                'compiling',
            ],
        ];

        $applicationExecutingState = [
            'state' => 'executing',
            'meta_state' => [
                'pending' => false,
                'ended' => false,
                'succeeded' => false,
            ],
            'previous_states' => [
                'awaiting',
                'compiling',
                'executing',
            ],
        ];

        $applicationCompletingEventDeliveryState = [
            'state' => 'completing-event-delivery',
            'meta_state' => [
                'pending' => false,
                'ended' => false,
                'succeeded' => false,
            ],
            'previous_states' => [
                'awaiting',
                'compiling',
                'executing',
                'completing-event-delivery',
            ],
        ];

        $applicationCompleteState = [
            'state' => 'complete',
            'meta_state' => [
                'pending' => false,
                'ended' => true,
                'succeeded' => true,
            ],
            'previous_states' => [
                'awaiting',
                'compiling',
                'executing',
                'completing-event-delivery',
                'complete',
            ],
        ];

        $componentAwaitingState = $applicationAwaitingState;

        $componentRunningState = [
            'state' => 'running',
            'meta_state' => [
                'pending' => false,
                'ended' => false,
                'succeeded' => false,
            ],
            'previous_states' => [
                'awaiting',
                'running',
            ],
        ];

        $componentCompleteState = [
            'state' => 'complete',
            'meta_state' => [
                'pending' => false,
                'ended' => true,
                'succeeded' => true,
            ],
            'previous_states' => [
                'awaiting',
                'running',
                'complete',
            ],
        ];

        $awaitingRunningAwaitingAwaitingState = [
            'application' => $applicationAwaitingState,
            'compilation' => $componentRunningState,
            'execution' => $componentAwaitingState,
            'event_delivery' => $componentAwaitingState,
        ];

        $compilingRunningAwaitingAwaitingState = [
            'application' => $applicationCompilingState,
            'compilation' => $componentRunningState,
            'execution' => $componentAwaitingState,
            'event_delivery' => $componentAwaitingState,
        ];

        $compilingRunningAwaitingRunningState = [
            'application' => $applicationCompilingState,
            'compilation' => $componentRunningState,
            'execution' => $componentAwaitingState,
            'event_delivery' => $componentRunningState,
        ];

        $executingCompleteAwaitingRunningState = [
            'application' => $applicationExecutingState,
            'compilation' => $componentCompleteState,
            'execution' => $componentAwaitingState,
            'event_delivery' => $componentRunningState,
        ];

        $executingCompleteRunningRunningState = [
            'application' => $applicationExecutingState,
            'compilation' => $componentCompleteState,
            'execution' => $componentRunningState,
            'event_delivery' => $componentRunningState,
        ];

        $completingEventDeliveryCompleteCompleteRunningState = [
            'application' => $applicationCompletingEventDeliveryState,
            'compilation' => $componentCompleteState,
            'execution' => $componentCompleteState,
            'event_delivery' => $componentRunningState,
        ];

        $completeCompleteCompleteCompleteState = [
            'application' => $applicationCompleteState,
            'compilation' => $componentCompleteState,
            'execution' => $componentCompleteState,
            'event_delivery' => $componentCompleteState,
        ];

        return [
            'state changes' => [
                'notifications' => self::getStateChangeNotifications(),
                'expected' => [
                    [
                        'previous_state' => $awaitingRunningAwaitingAwaitingState,
                        'new_state' => $compilingRunningAwaitingAwaitingState,
                    ],
                    [
                        'previous_state' => $compilingRunningAwaitingAwaitingState,
                        'new_state' => $compilingRunningAwaitingRunningState,
                    ],
                    [
                        'previous_state' => $compilingRunningAwaitingRunningState,
                        'new_state' => $executingCompleteAwaitingRunningState,
                    ],
                    [
                        'previous_state' => $executingCompleteAwaitingRunningState,
                        'new_state' => $executingCompleteRunningRunningState,
                    ],
                    [
                        'previous_state' => $executingCompleteRunningRunningState,
                        'new_state' => $completingEventDeliveryCompleteCompleteRunningState,
                    ],
                    [
                        'previous_state' => $completingEventDeliveryCompleteCompleteRunningState,
                        'new_state' => $completeCompleteCompleteCompleteState,
                    ],
                ],
            ],
            'events' => [
                'notifications' => self::getEventNotifications(),
                'expected' => [
                    [
                        'job' => self::JOB_LABEL,
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
                        'job' => self::JOB_LABEL,
                        'sequence_number' => 2,
                        'type' => 'lifecycle/compilation-started',
                        'body' => [],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                    [
                        'job' => self::JOB_LABEL,
                        'sequence_number' => 3,
                        'type' => 'compilation/started',
                        'body' => [
                            'source' => 'test.yml',
                        ],
                        'label' => 'test.yml',
                        'reference' => md5(self::JOB_LABEL . 'test.yml'),
                    ],
                    [
                        'job' => self::JOB_LABEL,
                        'sequence_number' => 4,
                        'type' => 'compilation/passed',
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
                        'job' => self::JOB_LABEL,
                        'sequence_number' => 5,
                        'type' => 'lifecycle/compilation-completed',
                        'body' => [],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                    [
                        'job' => self::JOB_LABEL,
                        'sequence_number' => 6,
                        'type' => 'lifecycle/execution-started',
                        'body' => [],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                    [
                        'job' => self::JOB_LABEL,
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
                        'job' => self::JOB_LABEL,
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
                            'name' => 'verify page is open',
                        ],
                        'label' => 'verify page is open',
                        'reference'=> md5(self::JOB_LABEL . 'test.yml' . 'verify page is open'),
                    ],
                    [
                        'job' => self::JOB_LABEL,
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
                        'job' => self::JOB_LABEL,
                        'sequence_number' => 10,
                        'type' => 'lifecycle/execution-completed',
                        'body' => [],
                        'label' => self::JOB_LABEL,
                        'reference' => md5(self::JOB_LABEL),
                    ],
                    [
                        'job' => self::JOB_LABEL,
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
    private static function decodeLoggedNotification(array $logSection): array
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

    private static function renderLogAssertionFailureMessage(): string
    {
        return (string) json_encode(
            [
                'notification_count' => count(self::$logSections),
                'notification_bodies' => self::$notifications,
            ],
            JSON_PRETTY_PRINT,
        );
    }

    /**
     * @return array<array<mixed>>
     */
    private static function getStateChangeNotifications(): array
    {
        return self::filterNotificationsByExistentKey('previous_state');
    }

    /**
     * @return array<array<mixed>>
     */
    private static function getEventNotifications(): array
    {
        return self::filterNotificationsByExistentKey('job');
    }

    /**
     * @return array<array<mixed>>
     */
    private static function filterNotificationsByExistentKey(string $key): array
    {
        $notifications = [];

        foreach (self::$notifications as $loggedNotification) {
            if (array_key_exists($key, $loggedNotification)) {
                $notifications[] = $loggedNotification;
            }
        }

        return $notifications;
    }
}
