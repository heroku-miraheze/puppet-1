# (old) SSL secure.wm host
# https://secure.wikimedia.org | http://en.wikipedia.org/wiki/Wikipedia:Secure_server
class misc::secure {
	system_role { "misc::secure": description => "secure.wikimedia.org" }
	apache_module { rewrite: name => "rewrite" }
	apache_site { secure: name => "secure.wikimedia.org" }
}
