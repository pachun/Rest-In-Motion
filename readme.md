# Rest In Motion

RestKit's object mapping functionality is broken in Ruby Motion. Rest In Motion is a thin layer overtop of the 
working component of RestKit (RKClient), that reimplements object mapping in ruby. It also restyles the way 
regular request are done.

# Examples

First you should initialize the "request god" in your application's delegate in the 
application:didFinishLaunchingWithOptions: method and save it to an app delegate instance variable so that it never
leaves memory. You should initialize it with ".instance" and pass it the base URL of the server you're going to 
communicate with (don't add a trailing slash to the URL):

```ruby
class AppDelegate
  attr_accessor :request_god

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @request_god = RequestGod.instance "http://yourserversURLwithNOtrailingslash.com"
  
    @window = UIWindow.alloc.initWithFrame UIScreen.mainScreen.bounds
    @window.rootViewController = RegularRequestViewController.alloc.init
    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible
    true
  end
end
```

Now you can use the request god in you view controller's to make simple HTTP Get, Post, Put, and Delete requests, like so:

```ruby
class RegularRequestExampleViewController < UIViewController
  attr_accessor :login_request_id

  def init
    super
    driver
    self
  end

  def driver
  
    # use .instance to get ahold of the request god you initialized in your app delegate
    @request_god = RequestGod.instance
    
    # use .RegularRequest to spawn a simple HTTP Get, Post, etc. Pass in the resource path, method, and callback delegate
    login_request = @request_god.RegularRequest('/tokens.json', method:POST, delegate:self)
    
    # optionally, you can add post/put parameters
    login_request.params = { "email" => "n0x10s.gas@gmail.com", "password" => "password" }
    
    # optionally, you can set a specific callback for when the request results return; more on this later
    # login_request.callback = :"login_response:"
    
    # save the request ID
    @login_request_id = login_request.id
    
    # send the request
    login_request.send
  end

  # called only if you assigned login_request.callback
  def login_response(response)
    puts "response to login request: #{response.str}"
  end

  # called if no login_request.callback was assigned
  def received(response, id:id)
    puts "response to login request: #{response.str}" if id == @login_request_id
  end
end
```

The default callback for all requests is
```ruby
received(response, id:id)
```
If you use this, save the ID's of all the requests you create (when you create them) so that you know which 
request you're receiving the resposne for. Optionally, you can set the
```ruby
login_request.callback = :"some_method_with_one_parameter:"
```
If you do this, the result of the login_request will not trigger the received: id: method, but the specified one instead. 
And it will not pass in the request id because you already know which request's response you're parsing because you're 
in its unique callback function.

# Object Mapping Example

```ruby
class ResourceRequestViewController < UIViewController
  attr_accessor :game_mapping, :team_mapping

  def init
    super
    driver
    self
  end

  def driver
    request_god = RequestGod.instance
    games_request = request_god.ResourceRequest('/castle/seasons/4/games.json?auth_token=tok', method:GET, delegate:self)

    # use mappings hash to map { json_key => object_var_name }
    @game_mapping = ObjectMapping.new(Game)
    @game_mapping.mappings = { "league_id" => "league_id", "season_id" => "season_id", "rounds_count" => "num_rounds", "home_team" => "home_team" }

    # use sub_mappings hash to map { object_var_name => object_mapping }
    @team_mapping = ObjectMapping.new(Team)
    @team_mapping.mappings = { "url" => "url", "id" => "id", "name" => "name" }
    @game_mapping.sub_mappings = { "home_team" => @team_mapping }

    games_request.root_mapping = game_mapping
    games_request.callback = :"games:"
    games_request.send
  end

  def games(games)
    games.each { |game| puts "#{game}" } # automatically unserialized and mapped to an array of game ojects
    
    # to reserialize the games into json:
    # games.each { |game| puts "#{@game_mapping.serialize(game)}" }
  end
end
```

Hopefully this is clear. Note that for this code to work you should have a Game class defined somewhere in your project 
with member variables: league_id, season_id, num_rounds, and home_team. You should also have a Team class defined 
somewhere with member variables: url, id, and name.

# Install

To install this, install cocoapods:

    gem install cocoapods
    pod setup
    
And I like to be able to search for pods from the command line. If you would too (though not necessary), add:

    brew install appledoc --HEAD
    ln -sf "`brew --prefix`/Cellar/appledoc/HEAD/Templates" ~/Library/Application\ Support/appledoc
    
Now install motion-cocoapods

    gem install motion-cocoapods
    
Now add these two lines under the existing require in your rakefile:
```ruby
    require 'rubygems'
    require 'motion-cocoapods'
```
    
And add these lines:
```ruby
    Motion::Project::App.setup do |app|
      # stuff
      app.pods do
        dependency 'RestKit/Network'
        dependency 'RestKit/UI'
        dependency 'RestKit/Testing'
        dependency 'RestKit/ObjectMapping'
        dependency 'RestKit/ObjectMapping/CoreData'
      end
    end
```

Finally, from within your projects root directory (assuming you've initialized a git repo here) do:

    git submodule add git@github.com:pachun/Rest-In-Motion.git ./app/rim
    rake

You should also modify your .gitignore to ignore the restkit build files so you're not pushing and pulling an 
extra library every time you make a commit. Add this line to your .gitignore:

    vendor/
    
On a side note, if you push your project to your own repo and then pull it later on, you will have to reinitialize 
Rest In Motion like so:

    git pull git://yourrepohere.git
    cd ./yourrepohere
    git submodule init
    git submodule update
    
That should be all! I hope this is helpful!