module DogsHelper
	def dog_like_html(dog)
		like_count_html = "<i class='fa fa-heart'></i><span>Like<span class='like-count'>#{dog.get_upvotes.size}</span></span>".html_safe

		if current_user && dog.owner != current_user
			link_to(like_count_html, like_dog_path(dog), method: :put, remote: true, class: "like-dog like-button #{current_user.voted_up_on?(dog) ? 'liked' : ''}")
		elsif current_user.nil?
			link_to(like_count_html, new_user_registration_path, class: 'like-dog like-button')
		else
			content_tag(:span, like_count_html, class: 'like-dog like-button like-button-disabled')
		end
	end
end
