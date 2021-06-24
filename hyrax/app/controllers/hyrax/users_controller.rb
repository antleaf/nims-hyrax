require_dependency Hyrax::Engine.config.root.join('app', 'controllers', 'hyrax', 'users_controller.rb').to_s

class Hyrax::UsersController
  def index
    authenticate_user! if Flipflop.hide_users_list?
    authorize! :index, ::User
    @users = search(params[:uq])
  end

  def show
    user = User.find_by(user_identifier: params[:id])
    if user.orcid.present?
      redirect_to "https://samurai.nims.go.jp/orcid/#{Hyrax::OrcidValidator.match(user.orcid)}"
      return
    end

    render file: 'public/404.html', status: 404
  end
end
