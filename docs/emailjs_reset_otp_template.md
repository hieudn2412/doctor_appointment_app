# EmailJS Reset OTP Template

Use this template in EmailJS for forgot/reset password flow.

## Subject

```text
{{subject}}
```

## HTML Content

```html
<div style="font-family: Arial, sans-serif; font-size: 14px; color: #111827; line-height: 1.6;">
  <p>Hello {{to_name}},</p>

  <p>You requested to reset your password for <strong>{{app_name}}</strong>.</p>

  <p style="margin: 16px 0 8px;">Your OTP code is:</p>
  <p style="font-size: 26px; font-weight: 700; letter-spacing: 2px; margin: 0 0 12px;">
    {{passcode}}
  </p>

  <p>This OTP is valid for {{expire_minutes}} minutes (until <strong>{{time}}</strong>).</p>

  <p style="margin-top: 16px;">
    Do not share this code with anyone. If you did not request this, you can ignore this email.
  </p>

  <p style="margin-top: 20px;">Regards,<br /><strong>{{app_name}}</strong></p>
</div>
```

## Variables expected from app code

- `subject`
- `to_email`
- `to_name`
- `passcode` (also available as `otp_code` and `otp`)
- `expire_minutes`
- `time`
- `app_name` (also available as `company_name`)
