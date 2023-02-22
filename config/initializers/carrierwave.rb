if Rails.env.production?
  CarrierWave.configure do |config|
    config.storage = :fog
    config.fog_credentials = {
      provider: 'Google',
      google_storage_access_key_id: 'slice-749@slice-378415.iam.gserviceaccount.com',
      google_storage_secret_access_key: "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCTK8fYmrI8haum\nNTkL9YISVwEK3VUPQpZ4oghO12Xzki1lJJ7E9YcJ163ILzYeiTg2apNBttqD9rQE\n0Mh94eErNQE1HchGjUxAF5egTq3567tyBVvk5irpUvTh633IeBSDrI34NWkvgwvh\nN8F3bp5YxrWelOrmtAiDIwSa5shPmp7cA57e5bGYqMHhzL5Bp1/uxIH+6mkxw+Rc\nabs0CrBTUADjgbsvNsz3PrVVntEdsLnkSLIvKfWdeE3XYoO7LyPhKraP3pFiZ2fA\n81SxrdZFCJGpO1b0QDRZJNgeUMpwX/Nh4xiJ90NNpd0qwqFDUaEo2im/7dx7uqFb\n6d0bIChTAgMBAAECggEAJb2v+cmuFJw46R4z+2+hxB9Auq8I3al3Wgc/dyyAziY5\n8vqhpqPKVglT3QbSa6FH45iQG+WPAxF0l9mM2M9gxYpJvXvePM2GdNc4AJm8vt8n\nijV6m+g0r/Igr4ELGCpHJH9PRww3ZcJG/SIlwIGDJQQMVlcdKD2aAzsrNqghTVxX\ndYEhYvJ3wfyC6z1eISQ5/7Y3o+clj+hQ5HWgKT/51F1rL6enXPzuqTG7dCiYlb0M\nwq+SuNBbcMvz7Oltwwy8qUTT2a4S64XyP4Y2cVFynYzDOkqent7CD35zH+ddSWuK\nP+5RkfJPOnz2h4WBg95TeV+XcWi+8vqpD72WqFEpzQKBgQDGi681zYc825OBV1P4\n8YBO67tutRG2+17tUo6djmZP+d3qx/u3NlcUCtnuNmJjB0f1nh8iS9fM7dzPrddQ\npdET2Sh04GQ950GQSiAX6aoIkOZWNbT4VJu1KfANhI9zFnM1O8FcdZgU3idYL7ua\nR7gW7HPPuNWOyu6lLJOhh/JuVQKBgQC9wkAAPRhgjIyTM8X4NChzUFXoqMjPOp+J\nLf55vDbRSn3QeuEoOP86V4X7VQFFpggYdXfu4qRTPg2OR67RQUY2oS0oAPyLb2AX\n1AoJKK4Zvip90TCk5cQPGh34xYpVt5Mym3EIlEstyJt3zhGugDiqY1j5FRU0tNTp\nGbhWVt6UBwKBgQC0suCtuPbCXp0q9E3KnhFGwqj9ovISdUj5+U8u+jEHzMM6MPRY\n1K3/4bhiY0C8HB5T3qs7TYeETV/P68mw7pkQ1W1KogbZiCVVqwD2goVr8mSQRaUE\n9gwYn6iIxQLBnccQxee/vI7DP0TTr+2wBmH3CxCEFxbWNL9puN5L/yyXWQKBgFO1\n0KQKT6mv9wetDEVdRQbxxqQ3aTa55s0OZDdxx0D2up/wxUkIM9eZ6rogGsqN3v5j\nO8A/bTxnoHVGvCEFyaKp4ZDHNqGQRXTdjnvR3VPv5zDPysTDs4TyAYzQICGGNUJa\n/jdJrAyLdcIZPwWa/OR1pTdkjJFOwKoANaio89GbAoGALd5SITpoVHSjD6ppuiom\noTDr6KFDrp+2VnOn9cEDIxPfs8X/wIwoabHvksMCrm0IBoYl4kiV86i5yYL81AMj\nsZGvIFLFgzI9v+cgTaTQZ7J/yMPM5xhLNTVhA5jXM/6KPI23LOIR9KkDQZlZMKJt\nBZjMl2I58tU5kPXgM0sZzNQ=\n-----END PRIVATE KEY-----\n"
    }
    config.fog_directory = 'slice-app'
    signed_url_version: :v4
  end
else
  CarrierWave.configure do |config|
    config.storage = :file
  end
end