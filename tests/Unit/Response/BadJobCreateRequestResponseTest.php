<?php

declare(strict_types=1);

namespace App\Tests\Unit\Response;

use App\Response\BadJobCreateRequestResponse;
use PHPUnit\Framework\TestCase;
use Symfony\Component\HttpFoundation\Response;

class BadJobCreateRequestResponseTest extends TestCase
{
    public function testCreateLabelMissingResponse()
    {
        $response = BadJobCreateRequestResponse::createLabelMissingResponse();

        self::assertResponse('label missing', 100, $response);
    }

    public function testCreateCallbackUrlMissingResponse()
    {
        $response = BadJobCreateRequestResponse::createCallbackUrlMissingResponse();

        self::assertResponse('callback url missing', 200, $response);
    }

    public function testCreateJobAlreadyExistsResponse()
    {
        $response = BadJobCreateRequestResponse::createJobAlreadyExistsResponse();

        self::assertResponse('job already exists', 300, $response);
    }

    public function testCreateStateNotPresentResponse()
    {
        $state = 'unknown';

        $response = BadJobCreateRequestResponse::createJobStateNotPresentResponse($state);

        self::assertResponse('job state "unknown" not present', 400, $response);
    }

    private static function assertResponse(string $expectedMessage, int $expectedCode, Response $response): void
    {
        self::assertSame('application/json', $response->headers->get('content-type'));
        self::assertSame(
            [
                'type' => 'job-create-request',
                'message' => $expectedMessage,
                'code' => $expectedCode,
            ],
            json_decode((string) $response->getContent(), true)
        );
    }
}
