<?php

declare(strict_types=1);

namespace App\Tests\Services\InvokableFactory;

use App\Entity\Callback\CallbackInterface;

class CallbackSetup
{
    /**
     * @var CallbackInterface::TYPE_*
     */
    private string $type;

    /**
     * @var array<mixed>
     */
    private array $payload;

    /**
     * @var CallbackInterface::STATE_*
     */
    private string $state;

    public function __construct()
    {
        $this->type = CallbackInterface::TYPE_COMPILE_FAILURE;
        $this->payload = [];
        $this->state = CallbackInterface::STATE_AWAITING;
    }

    /**
     * @return CallbackInterface::TYPE_*
     */
    public function getType(): string
    {
        return $this->type;
    }

    /**
     * @return array<mixed>
     */
    public function getPayload(): array
    {
        return $this->payload;
    }

    /**
     * @return CallbackInterface::STATE_*
     */
    public function getState(): string
    {
        return $this->state;
    }

    /**
     * @param CallbackInterface::STATE_* $state
     *
     * @return $this
     */
    public function withState(string $state): self
    {
        $new = clone $this;
        $new->state = $state;

        return $new;
    }
}
