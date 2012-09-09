#sorry you need to set up your own test data for this to work

passed = 0
failed = 0

url = "http://www.yourdrupalsite.com/node/5"

# Should handle revoke emails and orders
description = "Should revoke emails that show up in the revocation list"
data="fakebuyer123@fake12342312.com|0|00:22:41:2c:11:50|somebody"
result = %x(curl \"#{url}?data=#{data}\")
(result =~ /This License Has Been Revoked/) ? passed+=1 : (failed+=1; p "Test Failed: " + description + ", Result was :" + result);

description = "Should revoke orders that show up in the revocation list"
data="test@test.com|2|00:22:41:2c:11:50|somebody"
result = %x(curl \"#{url}?data=#{data}\")
(result =~ /This License Has Been Revoked/) ? passed+=1 : (failed+=1; p "Test Failed: " + description + ", Result was :" + result);

# Should validate completed order exists for email and order id
description = "Should fail if given a correct email but incorrect order number"
data="xywdaaz@gmail.com|1|00:22:41:2c:11:50|somebody"
result = %x(curl \"#{url}?data=#{data}\")
(result =~ /Incorrect Email or Order Number/) ? passed+=1 : (failed+=1; p "Test Failed: " + description + ", Result was :" + result);

description = "Should fail if given a correct email and order number but order status is complete"
data="someemail@gmail.com|1|00:22:41:2c:11:50|somebody"
result = %x(curl \"#{url}?data=#{data}\")
(result =~ /Incorrect Email or Order Number/) ? passed+=1 : (failed+=1; p "Test Failed: " + description + ", Result was :" + result);

# Should validate duplicate request
description = "Should return pre-existing license if this is a duplicate request and not generate a new key"
data="xywdaaz@gmail.com|7|00:22:41:2c:11:50|somebody"
result = %x(curl \"#{url}?data=#{data}\")
(result =~ /existing_license/) ? passed+=1 : (failed+=1; p "Test Failed: " + description + ", Result was :" + result);

# Shouldn't test usage limit
description = "Shouldn't allow more than 5 licenses per year"
data="xywdaza@gmail.com|7|00:22:41:2c:11:50|friend6"
result = %x(curl \"#{url}?data=#{data}\")
(result =~ /Usage Limit Exceeded/) ? passed+=1 : (failed+=1; p "Test Failed: " + description + ", Result was :" + result);


puts "#{passed} test(s) passed. #{failed} test(s) failed"