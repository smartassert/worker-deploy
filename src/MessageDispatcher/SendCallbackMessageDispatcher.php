<?php

declare(strict_types=1);

namespace App\MessageDispatcher;

use App\Event\CallbackEventInterface;
use App\Event\CallbackHttpErrorEvent;
use App\Event\JobTimeoutEvent;
use App\Event\SourceCompile\SourceCompileFailureEvent;
use App\Event\TestExecuteDocumentReceivedEvent;
use App\Message\SendCallback;
use App\Model\Callback\StampedCallbackInterface;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;
use Symfony\Component\Messenger\Envelope;
use Symfony\Component\Messenger\MessageBusInterface;
use webignition\BasilWorker\PersistenceBundle\Entity\Callback\CallbackInterface;
use webignition\BasilWorker\PersistenceBundle\Services\CallbackStateMutator;

class SendCallbackMessageDispatcher implements EventSubscriberInterface
{
    private MessageBusInterface $messageBus;
    private CallbackStateMutator $callbackStateMutator;

    public function __construct(MessageBusInterface $messageBus, CallbackStateMutator $callbackStateMutator)
    {
        $this->messageBus = $messageBus;
        $this->callbackStateMutator = $callbackStateMutator;
    }

    public static function getSubscribedEvents()
    {
        return [
            CallbackHttpErrorEvent::class => [
                ['dispatchForCallbackEvent', 0],
            ],
            SourceCompileFailureEvent::class => [
                ['dispatchForCallbackEvent', 0],
            ],
            TestExecuteDocumentReceivedEvent::class => [
                ['dispatchForCallbackEvent', 0],
            ],
            JobTimeoutEvent::class => [
                ['dispatchForCallbackEvent', 0],
            ],
        ];
    }

    public function dispatchForCallbackEvent(CallbackEventInterface $event): void
    {
        $callback = $event->getCallback();

        $this->callbackStateMutator->setQueued($callback);
        $this->messageBus->dispatch($this->createCallbackEnvelope($callback));
    }

    /**
     * @param CallbackInterface $callback
     *
     * @return Envelope
     */
    private function createCallbackEnvelope(CallbackInterface $callback): Envelope
    {
        $sendCallbackMessage = new SendCallback((int) $callback->getId());
        $stamps = [];

        if ($callback instanceof StampedCallbackInterface) {
            $stampCollection = $callback->getStamps();
            if ($stampCollection->hasStamps()) {
                $stamps = $stampCollection->getStamps();
            }
        }

        return new Envelope($sendCallbackMessage, $stamps);
    }
}