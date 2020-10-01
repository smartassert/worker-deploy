<?php

declare(strict_types=1);

namespace App\Request;

use App\Model\Manifest;
use Symfony\Component\HttpFoundation\File\UploadedFile;
use Symfony\Component\HttpFoundation\Request;

class AddSourcesRequest extends AbstractEncapsulatingRequest
{
    public const KEY_MANIFEST = 'manifest';

    private ?Manifest $manifest;

    /**
     * @var UploadedFile[]
     */
    private array $sources = [];

    public function processRequest(Request $request): void
    {
        $files = $request->files;

        $manifest = $files->get(self::KEY_MANIFEST);
        $this->manifest = $manifest instanceof UploadedFile ? new Manifest($manifest) : null;

        $files->remove(self::KEY_MANIFEST);

        foreach ($files as $name => $file) {
            if ($file instanceof UploadedFile) {
                $this->sources[$name] = $file;
            }
        }
    }

    public function getManifest(): ?Manifest
    {
        return $this->manifest;
    }

    /**
     * @return UploadedFile[]
     */
    public function getSources(): array
    {
        return $this->sources;
    }
}