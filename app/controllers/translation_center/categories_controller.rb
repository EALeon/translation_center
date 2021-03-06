require_dependency "translation_center/application_controller"

module TranslationCenter
  class CategoriesController < ApplicationController
    before_filter :can_admin?, only: [ :destroy ]
    before_filter :set_page_number, except: :destroy

    # GET /categories
    # GET /categories.json
    def index
      @categories = Category.all
  
      respond_to do |format|
        format.html # index.html.erb
        format.json { render json: @categories }
      end
    end
  
    # GET /categories/1
    # GET /categories/1.json
    def show
      @category = Category.find(category_params[:id])
      @page_name = params[:page_name]
      session[:current_filter] = category_params[:filter] || session[:current_filter]
      if params[:page].blank?
        @keys = @category.send("#{session[:current_filter]}_keys", session[:lang_to]).offset(@page - 1).limit(TranslationKey::PER_PAGE)
      else
        @keys = @category.keys.where("name LIKE ? ", "%#{@page_name}%")
      end
      @untranslated_keys_count = @category.untranslated_keys(session[:lang_to]).count
      @translated_keys_count = @category.translated_keys(session[:lang_to]).count
      @pending_keys_count = @category.pending_keys(session[:lang_to]).count
      @all_keys_count = @untranslated_keys_count + @translated_keys_count + @pending_keys_count
      respond_to do |format|
        format.html # show.html.erb
        format.js
      end
    end

    def pages
      @category = Category.find(category_params[:id])
      @keys = @category.keys.where("name LIKE ? ", "%#{page_name}%")
    end

    # GET /categories/1/more_keys.js
    def more_keys
      @category = Category.find(category_params[:category_id])
      @keys = @category.send("#{session[:current_filter]}_keys", session[:lang_to]).offset(@page - 1).limit(TranslationKey::PER_PAGE)
      respond_to do |format|
        format.js { render 'keys' }
      end
    end

  
    # DELETE /categories/1
    # DELETE /categories/1.json
    def destroy
      @category = Category.find(category_params[:id])
      @category.destroy
  
      respond_to do |format|
        format.html { redirect_to categories_url }
        format.json { head :no_content }
      end
    end

    def category_params
      params.permit!
    end
  end
end
