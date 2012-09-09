Software-Licensing-System-for-Ubercart
======================================

- About this module:
	This Drupal module allows someone who uses Ubercart to sell a software license 
	and generate license keys by having their application, written in any language, 
	communicate back to their Drupal site to retrieve and or generate SSL keys over http
	in a secure manner with a simple set of usage limitations. 

	This is my first module release for Drupal. 
	Any refactoring or code style suggestions are highly encouraged.

	This module was build for drupal 6, which is the version i was using when writing this,
	however I didn't code any specific function that would not work with other drupal versions.
	Testers for other drupal versions are more than welcome to contact me.

	This module is made for people with at least a rudimentary understanding of php code and ssl
	keypairs. Part of the security of this system is in the customization you add to the code
	yourself. The unique tokens you choose to use and hash/obfuscation algorithms you can optionally
	add make this harder to crack. 
	Think of this as a functional baseline implementation you can tailor to your own security needs.
	
	In time I may try to dummy proof the install but for now you'll probably need to read a bit of code 
	to get this to work for you properly.
	Code submissions for improvements are also welcome.

	This module depends on the following ubercart core modules.
		Cart, Conditional Actions, Order, Product, Token, Store


- High Level Design of the Ubercart software licensing system:

Server Side:
	Sets up a simple keygen php page to listen for http get requests from your software product.
		The required get request parameter is named "data" and 
		should be a unique string identifying the purchased software license. 
		for example: customer_name combined with macaddress, email and order_number  
		You can use any unique string you like. This request parameter can be sent 
		from your software application in the clear or hashed beforehand, whatever your preference. 
		It is not necessary for it to be a secret based on how keypair ssl works.
	Verifies that a ubercart order matching the keygen request exists and has been paid for.
	Verifies a revocation list in revoked_license_t for licenses you no longer wish to generate keys for. 
		(in case of a refunded order for example)
	Verifies if a key has already been returned for this specific unique identifying string.
		if so looks up the previously generated key and returns that instead of generating a new key.
	Verifies if the usage limit is exceeded. (counting entries in the license_t matching that order)
		In this version we default to maximum 5 keys generated per year for a given order.
	If the above verifications pass it then generates a license key using a 2048 bit ssl public/private 
		keypair you place on the server in a protected directory that isn't web accessible.
		It then stores the key in license_t to keep track of usage limits.
	A simple http text response is returned to be parsed by your software application.
	
	Step 1. 
		Place the uc_license_key_system in the standard /sites/all/modules folder.
	Step 2.
		Run the drupal module installer from the admin page of your site. This will create
		the necessary databases.
	Step 3. 
		Create a new content page from the admin section of drupal and paste in the 
		contents of the page.ph_p file. (you can of course tailor it to your needs before hand)
		* be sure to set the page's content type to "php code". 
	
Client Side:

	You need to implement this yourself in whatever language your software application is written.
	I personally have my clients enter their order email and order number into a trial
	application they download from my website to unlock the full version. 
	You can obviously change that around to be a downloaded key or some file
	they place in a certain folder or whatever you like. We just need a way of linking the user
	to the order placed in ubercart in a unique manner. 
	If the user shares their information with others they will run out of licenses 
	and that is how you will prevent piracy of your software product.
	
	Step 1. 
		Create a unique string identifying your user.
		ex: "order_num:email@address.com:mac:address:username";
	Step 2. 
		Send a request to the above mentioned server php file to retrieve a license key.
	Step 3. 
		Verify the response using the public key (which you store somewhere in your app).
		The public key can be hardcoded or obfuscated completely up to you.
		You just have to make it hard for pirates to swap in their own public key to 
		crack your software.
		The difficulty of this step varies depending on the language you coded in. 
		For Example, in C++ a great writeup on this is here: 
		http://www.zabkat.com/blog/27Jun10-openssl-keygen.htm
	Step 4. 
	 	Once a successful verification takes place you should store the license somewhere in the 
		app to remove the need to query the server for your license every time you want to 
		verify it. Alternatively you can permanently unlock the software after the first
		successful verification completely up to you. 
		
Customization:
	Here are a few things you will need or want to change.
	in file uc_license_key_system.module:
		line 105:
			$filename = "/home/you/yoursite.com/openssl/private.pem";
			#(change this to the safe non web accessible location of your private key on the server)
		line 94:
			$result = array(
			    		"email" => $tokens[0],
						"order_num" => $tokens[1],
					    "mac_addr" => $tokens[2],
					    "username" => $tokens[3],			
					);
			#(make this reflect the tokens you chose to be your unique identification string, if different)
		line 91:
			print t(" status : Error: Please contact customersupport@yoursite.com \n key : \n");
			#(put in your own customer support address or just remove the line)
		line 19:
			$usage_limit = 5; //times per year per order
			#(set this to whatever you want the yearly license limit to be).
		line 22:
			 AND   n.create_date > \'%s\'', $order_number, strtotime("1 year ago"));
			#(change this to be whatever time limit you prefer)
	
	
