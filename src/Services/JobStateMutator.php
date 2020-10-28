<?php

declare(strict_types=1);

namespace App\Services;

use App\Entity\Job;

class JobStateMutator
{
    private JobStore $jobStore;

    public function __construct(JobStore $jobStore)
    {
        $this->jobStore = $jobStore;
    }

    public function setCompilationRunning(): void
    {
        $this->set(Job::STATE_COMPILATION_RUNNING);
    }

    public function setCompilationFailed(): void
    {
        $this->set(Job::STATE_COMPILATION_FAILED);
    }

    private function set(string $state): void
    {
        if ($this->jobStore->hasJob()) {
            $job = $this->jobStore->getJob();
            $job->setState($state);
            $this->jobStore->store();
        }
    }
}