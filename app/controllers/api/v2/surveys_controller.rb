module Api
  module V2
    class SurveysController < ApplicationController
      include DataDumpActions
      before_action :authorize_user!, except: [:index, :show, :download, :md5]
      
      before_action :set_survey, only: [:show, :update, :destroy]
      before_action :set_basecamp, only: [:index, :show, :update, :destroy]
      
      before_action only: [:update] {
        authorize_change!(@survey.commander,
                          params[:survey][:commander])
      }
      before_action only: [:destroy] {
        authorize_change!(@survey.commander,
                          params[:user])
      }

      def index
        @surveys = filtered.page(page).
                                 per(per_page).
                                 order(ordering)
        render json: @surveys, serializer: PaginatedSerializer,
                                    each_serializer: SurveySerializer
      end

      def show
        render json: @survey
      end

      def create
        @survey = Survey.new(new_survey_params)

        if @survey.save
          render json: @survey, status: :created, 
                                     location: @survey
        else
          render json: @survey.errors, status: :unprocessable_entity
        end
      end

      def update
        @survey = Survey.find(params[:id])

        if @survey.update(edit_survey_params)
          head :no_content
        else
          render json: @survey.errors, status: :unprocessable_entity
        end
      end

      def destroy
        @survey.destroy

        head :no_content
      end

      private

      def set_survey
        @survey = Survey.find(params[:id])
      end
      
      def set_basecamp
        @basecamp = if params[:basecamp_id]
                      Basecamp.find(params[:basecamp_id]) 
                    else
                      @survey.basecamp if @survey
                    end
      end

      def survey_params
        params.require(:survey)
              .permit(:basecamp_id,
                      :commander,
                      :resource, 
                      :notes,
                      :image_url,
                      :carbon,
                      :iron,
                      :nickel,
                      :phosphorus,
                      :sulphur,
                      :arsenic,
                      :chromium,
                      :germanium,
                      :manganese,
                      :selenium,
                      :vanadium,
                      :zinc,
                      :zirconium,
                      :cadmium,
                      :mercury,
                      :molybdenum,
                      :niobium,
                      :tin,
                      :tungsten,
                      :antimony,
                      :polonium,
                      :ruthenium,
                      :technetium,
                      :tellurium,
                      :yttrium)
      end

      def new_survey_params
        {
          basecamp_id: params[:basecamp_id],
          commander: params[:commander]
        }.merge(survey_params)
      end
      
      def edit_survey_params
        params = survey_params
        params[:survey].delete(:commander) if params[:survey]
        params
      end

      def filtered
        Survey.by_world_id(params[:world_id])
                  .by_basecamp_id(params[:basecamp_id])
                  .by_resource(params[:resource])
                  .by_commander(params[:commander])
                  .updated_before(params[:updated_before])
                  .updated_after(params[:updated_after])
      end
      
      def per_page
        params[:per_page] || 100
      end
    end
  end
end
