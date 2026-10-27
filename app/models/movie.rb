class Movie < ActiveRecord::Base
  def self.all_ratings
    %w[G PG PG-13 R]
  end

  def self.with_ratings(ratings, sort_by)
    if ratings.nil?
      all.order sort_by
    else
      where(rating: ratings.map(&:upcase)).order sort_by
    end
  end

  def self.find_in_tmdb(search_params, api_key = ENV['TMDB_API_KEY'])
    title = search_params[:title]
    year = search_params[:release_year]
    language = search_params[:language]

    raise 'TMDb API key is missing' if api_key.blank?

    query_params = {
      api_key: api_key,
      query: title,
      year: year.presence
    }.compact

    query_params[:language] = 'en-US' if language == 'en'

    response = Faraday.get(
      'https://api.themoviedb.org/3/search/movie',
      query_params
    )

    unless response.success?
      Rails.logger.error(
        "TMDb request failed: HTTP #{response.status} - #{response.body}"
      )
      raise "TMDb request failed with status #{response.status}"
    end

    results = JSON.parse(response.body).fetch('results', [])

    results.filter_map do |result|
      next if Movie.exists?(
        title: result['title'],
        release_date: result['release_date'].presence
      )

      Movie.new(
        title: result['title'],
        description: result['overview'],
        release_date: result['release_date'].presence,
        rating: 'R'
      )
    end
  end
end
