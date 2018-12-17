aws# ecb_sheet [![Build Status](https://travis-ci.org/jonas-lantto/ecb_sheet.svg)](https://travis-ci.org/jonas-lantto/ecb_sheet)

Simple utility to generate an excel sheet with currency rates from European Central Bank(ECB)

## Description
Utility generates two sheets within one excel workbook.

-   Named Table (FxRates) with conversion rates from currencies to selected target currency
-   Date series with conversion rates between selected currencies (90 days default)

## Excel usage
In Excel, use <code>=VLOOKUP("GBP";FxRates;2;false)</code> to get conversion rate for GBP.

Separator differs depending on locale

