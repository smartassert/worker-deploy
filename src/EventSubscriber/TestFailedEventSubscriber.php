<?php

declare(strict_types=1);

namespace App\EventSubscriber;

use App\Event\TestFailedEvent;
use App\Repository\TestRepository;
use App\Services\JobStateMutator;
use App\Services\JobStore;
use App\Services\TestStateMutator;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class TestFailedEventSubscriber implements EventSubscriberInterface
{
    private JobStateMutator $jobStateMutator;
    private TestStateMutator $testStateMutator;
    private JobStore $jobStore;
    private TestRepository $testRepository;

    public function __construct(
        JobStateMutator $jobStateMutator,
        TestStateMutator $testStateMutator,
        JobStore $jobStore,
        TestRepository $testRepository
    ) {
        $this->jobStateMutator = $jobStateMutator;
        $this->testStateMutator = $testStateMutator;
        $this->jobStore = $jobStore;
        $this->testRepository = $testRepository;
    }

    public static function getSubscribedEvents()
    {
        return [
            TestFailedEvent::class => [
                ['setTestStateToFailed', 0],
                ['setJobStateToCancelled', 0],
                ['cancelAwaitingTests', 0],
            ],
        ];
    }

    public function setTestStateToFailed(TestFailedEvent $event): void
    {
        $this->testStateMutator->setFailed($event->getTest());
    }

    public function setJobStateToCancelled(): void
    {
        $job = $this->jobStore->getJob();

        if (false === $job->isFinished()) {
            $this->jobStateMutator->setExecutionCancelled();
        }
    }

    public function cancelAwaitingTests(): void
    {
        $awaitingTests = $this->testRepository->findAllAwaiting();
        foreach ($awaitingTests as $test) {
            $this->testStateMutator->setCancelled($test);
        }
    }
}