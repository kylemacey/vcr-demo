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

## Commit #2

Now, our requirements have changed. We want to get a fortune from the internet, because people are sick of getting the same fortune over and over again.

```diff
diff --git a/lib/fortune.rb b/lib/fortune.rb
index b6c8acc..ccec95e 100644
--- a/lib/fortune.rb
+++ b/lib/fortune.rb
@@ -13,8 +13,10 @@ class Fortune
   private

   def get_parable
-    type = %w{good bad ok}.sample
-    "Today will be a #{type} day"
+    open("http://yerkee.com/api/fortune") do |r|
+      data = JSON.parse(r.read)
+      return data["fortune"]
+    end
   end

   def formatted_date
```

### Per example testing

We add the dependency and configuration for VCR to our spec helper, and we add the `:vcr` tag to `fortune_spec.rb`, since we know we're adding a network request there.

We run our tests and see that they pass!

```
rspec -r per_example_spec_helper.rb spec/fortune_spec.rb
```

![image](https://user-images.githubusercontent.com/519171/70642709-b2509700-1c0d-11ea-9537-55ff53545754.png)

We commit, and push up to CI, but we see we have some failing tests. I didn't set up CI for this repo, but I have a script that emulates what a CI would be doing for us in these cases.

```
bin/per_example_ci
```

![image](https://user-images.githubusercontent.com/519171/70643000-3e62be80-1c0e-11ea-89ba-f95c866ab5ea.png)


We get failures because our `Hat` spec tried to make a network request. Upon investigating `Hat`, we learn we would have made 20 of them, in fact!

```
1) Hat#random_fortune
     Failure/Error:
       open("http://yerkee.com/api/fortune") do |r|
         data = JSON.parse(r.read)
         return data["fortune"]
       end

     VCR::Errors::UnhandledHTTPRequestError:


       ================================================================================
       An HTTP request has been made that VCR does not know how to handle:
         GET http://yerkee.com/api/fortune

       There is currently no cassette in use. There are a few ways
       you can configure VCR to handle this request:
```

### Per request testing

Ok, same thing, except this time, we update the vcr dependency and configure our `around_http` implementation.

We run our tests and see that they pass, telling VCR to record once.

```
VCR_RECORD=once rspec -r per_request_spec_helper.rb spec/fortune_spec.rb
```

![image](https://user-images.githubusercontent.com/519171/70643462-0c9e2780-1c0f-11ea-8ab9-33755e357548.png)


This time, when we push up to CI, all of our tests pass, and we never notice that Hat was making 20 network requests.

```
bin/per_request_ci
```

![image](https://user-images.githubusercontent.com/519171/70643611-4ff89600-1c0f-11ea-809b-f5249d22e97a.png)


### Comparing cassettes

Here is the structure of our cassettes so far:

```
spec/fixtures
└── vcr_cassettes
    ├── per_example
    │   └── Fortune
    │       └── _message
    │           ├── has_today_s_formatted_date.yml
    │           └── outputs_a_fortune_on_a_new_line.yml
    └── per_request
        └── api
            └── fortune.yml
```

<sup>*\*we'll ignore the fact that the hostname isn't accounted for for now with per_request, since it isn't a need of our internal application right now and it could be easily configured*</sup>

I've left the repo in this state, so feel free to run any of the commands above and experiment. When you're ready, move on to the next step with

```
git checkout commit-3
```

## Commit #3

Ok, we've decided that we are ok with making 20 network requests in Hat right now. We don't want to try to scale prematurely, right? We need to get tests passing for `Hat`, so we add the `:vcr` tag after we've determined that we're accepting this change.

We run our tests locally to record the new cassettes:

```
rspec -r per_example_spec_helper.rb spec/fortune_spec.rb
```

![image](https://user-images.githubusercontent.com/519171/70644440-0315bf00-1c11-11ea-9a87-afc359876be4.png)

And we see that CI now passes when we push:

```
bin/per_example_ci
```

![image](https://user-images.githubusercontent.com/519171/70644503-22ace780-1c11-11ea-88b7-6d573fdde128.png)

One thing we want to note about the recorded cassettes, is that they tell the story that we're making 20 requests here:

```
 cat spec/fixtures/vcr_cassettes/per_example/Hat/_random_fortune/gets_a_fortune_from_one_of_its_fortunes.yml \
  | grep "^- request" \
  | wc -l
      20
```

Our per-request examples remain unchanged, because they are aready passing CI and sharing the one cassette, `spec/fixtures/vcr_cassettes/per_request/api/fortune.yml`

CI is passing! Move on to the next step with

```
git checkout commit-4
```

## Commit #4

Some time goes by. Everyone love our little fortune library. People can now make informed decisions about their lives because the prophetic hat has shown them the path to true happiness. However, we realize the problem that even though people are living out their long-lived dreams, they're often not dressed for the weather of the occassion, leading to frigid smiles and sweaty hugs. No big deal. We'll just have our fortune return the current temperature as well. We don't have a thermostat, so we'll connect to the internet to get the current temperature.

We get started in `fortune_spec.rb` to test our new behavior before implementing it.

```
diff --git a/spec/fortune_spec.rb b/spec/fortune_spec.rb
index 8234f14..655c170 100644
--- a/spec/fortune_spec.rb
+++ b/spec/fortune_spec.rb
@@ -9,5 +9,9 @@ describe Fortune, :vcr do
     it "outputs a fortune on a new line" do
       expect(subject.message).to match(/\n\w+/)
     end
+
+    it "outputs the current temperature" do
+      expect(subject.message).to match(/°C\Z/)
+    end
   end
 end
\ No newline at end of file
```

Our tests fail, as we'd expect.

```
rspec -r per_example_spec_helper.rb spec/fortune_spec.rb
```

```
  1) Fortune#message outputs the current temperature
     Failure/Error: expect(subject.message).to match(/°C\Z/)

       expected "It's 01/01/19\nRotten wood cannot be carved.\n\t\t-- Confucius, \"Analects\", Book 5, Ch. 9" to match /°C\Z/
       Diff:
       @@ -1,2 +1,4 @@
       -/°C\Z/
       +It's 01/01/19
       +Rotten wood cannot be carved.
       +                -- Confucius, "Analects", Book 5, Ch. 9

     # ./spec/fortune_spec.rb:14:in `block (3 levels) in <top (required)>'
```

### Per example testing

We add a call to the API in `fortune.rb`, and run our tests again to be notified that we've added a new network request:

```
 3) Fortune#message outputs the current temperature
     Failure/Error:
       open("https://www.metaweather.com/api/location/2487956/") do |r|
         data = JSON.parse(r.read)
         temp = ["consolidated_weather"].first["the_temp"]
         return "#{temp}°C"
       end

     VCR::Errors::UnhandledHTTPRequestError:


       ================================================================================
       An HTTP request has been made that VCR does not know how to handle:
         GET https://www.metaweather.com/api/location/2487956/
```

We're aware of the new request, and decide to delete our existing cassettes for `Fortune`, so they get re-recorded.

```
rm -rf spec/fixtures/vcr_cassettes/per_example/Fortune
rspec -r per_example_spec_helper.rb spec/fortune_spec.rb
```

And our tests pass!

![image](https://user-images.githubusercontent.com/519171/70645694-70c2ea80-1c13-11ea-8e2c-c9bb94464c7f.png)


We run our CI to get our PR merged, and we see that it fails because Hat is making network requests, and we forgot all about it.

![image](https://user-images.githubusercontent.com/519171/70645833-b5e71c80-1c13-11ea-88ac-f3e738276d6e.png)

```
2) Hat#random_fortune gets a fortune from one of its fortunes
     Failure/Error:
       open("https://www.metaweather.com/api/location/2487956/") do |r|
         data = JSON.parse(r.read)
         temp = ["consolidated_weather"].first["the_temp"]
         return "#{temp}°C"
       end

     VCR::Errors::UnhandledHTTPRequestError:


       ================================================================================
       An HTTP request has been made that VCR does not know how to handle:
         GET https://www.metaweather.com/api/location/2487956/

       VCR is currently using the following cassette:
         - /Users/kyle/w/tmp/vcr-demo/spec/fixtures/vcr_cassettes/per_example/Hat/_random_fortune/gets_a_fortune_from_one_of_its_fortunes.yml
```

### Per request testing

After adding our API call, we run our tests for `Fortune`:

```
rspec -r per_request_spec_helper.rb spec/fortune_spec.rb
```

They also fail because of the new network request to get the weather.

```
  1) Fortune#message has today's formatted date
     Failure/Error:
       open("https://www.metaweather.com/api/location/2487956/") do |r|
         data = JSON.parse(r.read)
         temp = ["consolidated_weather"].first["the_temp"]
         return "#{temp}°C"
       end

     VCR::Errors::UnhandledHTTPRequestError:


       ================================================================================
       An HTTP request has been made that VCR does not know how to handle:
         GET https://www.metaweather.com/api/location/2487956/
```

We set VCR to record the new request, since we expected these.

```
VCR_RECORD=once rspec -r per_request_spec_helper.rb spec/fortune_spec.rb
```

And our tests pass!

![image](https://user-images.githubusercontent.com/519171/70646112-3e65bd00-1c14-11ea-96af-4728720bf189.png)

We push up to run CI...

```
bin/per_request_ci
```

![image](https://user-images.githubusercontent.com/519171/70646165-5b9a8b80-1c14-11ea-95ad-fb69d7c1d957.png)

And CI passes, never letting us know that we're now making 20 more requests every time we pull a fortune out of a hat.

I've left the repo in this state, so have a look around, then run

```
git checkout commit-5
```