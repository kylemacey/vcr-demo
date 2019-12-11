# VCR Demo

## Commit #1

This app has a simple concept: We have fortunes that we put in a hat. Then we want to be able to select a fortune from the hat. Right now, it doesn't make any network requests, and leaves your fate in the hands of `Array#sample`.

You should be able to run the following commands and tests should pass just fine. The only extra dependency you should need right now is `rspec`.

```
rspec -r per_example_spec_helper.rb
rspec -r per_request_spec_helper.rb
```

When you've got a good grasp on what's going on, move on to the next step with

```
git checkout commit-2
```