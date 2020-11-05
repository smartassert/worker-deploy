<?php

declare(strict_types=1);

namespace App\Event\SourceCompile;

use webignition\BasilCompilerModels\ErrorOutputInterface;

class SourceCompileFailureEvent extends AbstractSourceCompileEvent
{
    private ErrorOutputInterface $errorOutput;

    public function __construct(string $source, ErrorOutputInterface $errorOutput)
    {
        parent::__construct($source);
        $this->errorOutput = $errorOutput;
    }

    public function getOutput(): ErrorOutputInterface
    {
        return $this->errorOutput;
    }
}