

{$if defined(__NO_MULTICFG_IMPL__)}
  {$define __NO_CRYPTO_IMPL__}
{$ifend}

{$if not defined(__NO_MULTICFG_IMPL__)}
  {$define __MULTICFG_IMPL__}
{$ifend}

{$if not defined(__NO_CRYPTO_IMPL__)}
  {$define __CRYPTO_IMPL__}
{$ifend}


