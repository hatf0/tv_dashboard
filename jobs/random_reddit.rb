require 'net/http'
require 'json'

placeholder = 'background-image:url(./assets/nyancat.gif)'

# set your widget event id as the first field, then the subreddit link as the second
subreddits = {
  'demotivational' => '/r/demotivational/hot.json?limit=100',
}

SCHEDULER.every '1m', first_in: 0 do |job|
  subreddits.each do |widget_event_id, subreddit|
    http = Net::HTTP.new('www.reddit.com', 443)
    http.use_ssl = true
    response = http.request(Net::HTTP::Get.new(subreddit, {'User-Agent' => 'reddit_dashing_widget'}))
    json = JSON.parse(response.body)

    if response.code == 429
	puts "We were rate limited :("
    end

    if json.nil? || json['data'].nil?
	puts "#{response.body}"
	send_event(widget_event_id, image: placeholder)
    else
	    if json['data']['children'].count <= 0
    		    puts "#{response.body}"
		    send_event(widget_event_id, image: placeholder)
	    else
		    if json['data']['children'].nil?
    			    puts "#{response.body}"
			    send_event(widget_event_id, image: placeholder)
		    else
			    urls = json['data']['children'].map{|child| child['data']['url'] }

			    valid_urls = urls.select{|url| url.downcase.end_with?('png', 'gif', 'jpg', 'jpeg')}
			    send_event(widget_event_id, image: "background-image:url(#{valid_urls.sample(1).first})")
		    end
	    end
    end
  end
end
