# AvantisSwapSDK

Inspired by the [Pancakeswap SDK](https://github.com/pancakeswap/pancake-swap-sdk).

You can refer to the Uniswap SDK documentation [uniswap.org](https://docs.uniswap.org/sdk/2.0.0/).

## Running tests

First clone the repository:

```sh
git clone git@github.com:ava-global/avantisswap-sdk-swift.git
```

Move into the avantisswap-sdk-swift working directory

```sh
cd avantisswap-sdk-swift/
```

Run tests

```sh
swift test
```

You should see output like the following:

```sh
$ swift test
Building for debugging...
Build complete! (5.16s)
Test Suite 'All tests' started at 2565-09-12 13:48:30.864
Test Suite 'AvantisSwapSDKPackageTests.xctest' started at 2565-09-12 13:48:30.865
Test Suite 'FractionSpec' started at 2565-09-12 13:48:30.865

...
...

Test Suite 'TradeSpec' passed at 2565-09-12 13:48:30.895.
    Executed 30 tests, with 0 failures (0 unexpected) in 0.016 (0.016) seconds
Test Suite 'AvantisSwapSDKPackageTests.xctest' passed at 2565-09-12 13:48:30.895.
    Executed 69 tests, with 0 failures (0 unexpected) in 0.029 (0.031) seconds
Test Suite 'All tests' passed at 2565-09-12 13:48:30.895.
    Executed 69 tests, with 0 failures (0 unexpected) in 0.029 (0.031) seconds
```
