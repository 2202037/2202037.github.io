<?php
/**
 * Input validation helper.
 *
 * Usage:
 *   $v = new Validator($data);
 *   $v->required(['email','password'])
 *     ->email('email')
 *     ->min('password', 8);
 *   if ($v->fails()) sendError('Validation failed', 422, $v->errors());
 */
class Validator {
    private array $data;
    /** @var array<string, string[]> */
    private array $errors = [];

    public function __construct(array $data) {
        $this->data = $data;
    }

    // ------------------------------------------------------------------ //
    // Rules
    // ------------------------------------------------------------------ //

    /** Assert that each field is present and non-empty. */
    public function required(array $fields): static {
        foreach ($fields as $field) {
            if (!isset($this->data[$field]) || trim((string)$this->data[$field]) === '') {
                $this->addError($field, "The {$field} field is required.");
            }
        }
        return $this;
    }

    /** Assert valid e-mail format. */
    public function email(string $field): static {
        if (isset($this->data[$field]) && !filter_var($this->data[$field], FILTER_VALIDATE_EMAIL)) {
            $this->addError($field, "The {$field} must be a valid email address.");
        }
        return $this;
    }

    /** Assert minimum string length. */
    public function min(string $field, int $min): static {
        $value = $this->data[$field] ?? '';
        if (strlen((string)$value) < $min) {
            $this->addError($field, "The {$field} must be at least {$min} characters.");
        }
        return $this;
    }

    /** Assert maximum string length. */
    public function max(string $field, int $max): static {
        $value = $this->data[$field] ?? '';
        if (strlen((string)$value) > $max) {
            $this->addError($field, "The {$field} must not exceed {$max} characters.");
        }
        return $this;
    }

    /** Assert value is one of the allowed choices. */
    public function in(string $field, array $choices): static {
        if (isset($this->data[$field]) && !in_array($this->data[$field], $choices, true)) {
            $this->addError($field, "The {$field} must be one of: " . implode(', ', $choices) . '.');
        }
        return $this;
    }

    /** Assert value is numeric. */
    public function numeric(string $field): static {
        if (isset($this->data[$field]) && !is_numeric($this->data[$field])) {
            $this->addError($field, "The {$field} must be a number.");
        }
        return $this;
    }

    /** Assert value is a positive integer. */
    public function positiveInt(string $field): static {
        $val = $this->data[$field] ?? null;
        if ($val !== null && (!is_numeric($val) || (int)$val <= 0)) {
            $this->addError($field, "The {$field} must be a positive integer.");
        }
        return $this;
    }

    /** Assert value matches a date (Y-m-d). */
    public function date(string $field): static {
        if (isset($this->data[$field])) {
            $d = \DateTime::createFromFormat('Y-m-d', $this->data[$field]);
            if (!$d || $d->format('Y-m-d') !== $this->data[$field]) {
                $this->addError($field, "The {$field} must be a valid date (YYYY-MM-DD).");
            }
        }
        return $this;
    }

    /** Assert value matches a time (H:i or H:i:s). */
    public function time(string $field): static {
        if (isset($this->data[$field])) {
            $val = $this->data[$field];
            if (!preg_match('/^\d{2}:\d{2}(:\d{2})?$/', $val)) {
                $this->addError($field, "The {$field} must be a valid time (HH:MM or HH:MM:SS).");
            }
        }
        return $this;
    }

    /** Assert password strength (min 8 chars, uppercase, lowercase, digit, special char). */
    public function strongPassword(string $field): static {
        $val = $this->data[$field] ?? '';
        if (
            strlen($val) < 8 ||
            !preg_match('/[A-Z]/', $val) ||
            !preg_match('/[a-z]/', $val) ||
            !preg_match('/\d/', $val) ||
            !preg_match('/[\W_]/', $val)
        ) {
            $this->addError(
                $field,
                "The {$field} must be at least 8 characters and contain uppercase, lowercase, a digit, and a special character."
            );
        }
        return $this;
    }

    /** Assert phone number format (digits, optional leading +). */
    public function phone(string $field): static {
        if (isset($this->data[$field])) {
            $val = preg_replace('/[\s\-()]/', '', (string)$this->data[$field]);
            if (!preg_match('/^\+?\d{7,15}$/', $val)) {
                $this->addError($field, "The {$field} must be a valid phone number.");
            }
        }
        return $this;
    }

    // ------------------------------------------------------------------ //
    // Result helpers
    // ------------------------------------------------------------------ //

    public function fails(): bool {
        return !empty($this->errors);
    }

    public function passes(): bool {
        return empty($this->errors);
    }

    /** @return array<string, string[]> */
    public function errors(): array {
        return $this->errors;
    }

    /** Get first error message for a field, or null. */
    public function firstError(string $field): ?string {
        return $this->errors[$field][0] ?? null;
    }

    // ------------------------------------------------------------------ //
    // Private
    // ------------------------------------------------------------------ //

    private function addError(string $field, string $message): void {
        $this->errors[$field][] = $message;
    }
}

/**
 * Parse JSON request body and return as array.
 * Merges with $_POST for form-data requests.
 */
function getRequestBody(): array {
    $json = file_get_contents('php://input');
    $decoded = json_decode($json ?: '{}', true);
    $body = is_array($decoded) ? $decoded : [];
    return array_merge($_POST, $body);
}

/**
 * Sanitise a string value for safe output.
 */
function sanitizeString(mixed $value): string {
    return htmlspecialchars(trim((string)$value), ENT_QUOTES, 'UTF-8');
}
