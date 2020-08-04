
{
  Delphi XE an higher ca use it without any problem...
}

{$i version.inc}

{$if not defined(DXE_UP)}
  {$if not defined(__NO_MULTICFG_IMPL__)}
    {$define __NO_MULTICFG_IMPL__}
  {$ifend}
{$ifend}    

{$if defined(__NO_MULTICFG_IMPL__)}
  {$define __NO_CRYPTO_IMPL__}
{$ifend}

{$if not defined(__NO_MULTICFG_IMPL__)}
  {$define __MULTICFG_IMPL__}
{$ifend}

{$if not defined(__NO_CRYPTO_IMPL__)}
  {$define __CRYPTO_IMPL__}
{$ifend}


