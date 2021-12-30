# Doorbell

Inspired by [this](https://twitter.com/_Dave__White_/status/1476277812344483841) tweet.

Still under development, absolutely not ready for prod. Like, I mean there are currently not even tests.

Uses [Foundry](https://github.com/gakonst/foundry) because I want to be a cool kid someday.

Some notes:

* Once an offer has been made, the offer creator cannot revoke the offer
* Similarly, once someone has staked tokens, they cannot withdraw unless the deadline passes without hitting the target amount of tokens
* If someone inputs an amount of tokens to stake that would exceed the target, only the amount up to the target is transferred - this prevents the offer creator from placing a large stake of tokens to dilute the value they need to pay for each share
* If the target token changes decimal places during the offer's duration, the original decimal value will be used (at least as of rn)