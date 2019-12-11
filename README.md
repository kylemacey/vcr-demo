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