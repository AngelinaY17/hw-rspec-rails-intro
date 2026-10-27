require 'rails_helper'
require 'spec_helper'

describe Movie, type: :model do
  describe 'searching TMDb by keyword' do

    it 'calls Faraday gem' do
      expect(Faraday).to receive(:get).and_call_original

      Movie.find_in_tmdb(
        title: 'hacker',
        language: 'en'
      )
    end

    it 'calls TMDb with valid API key' do
      Movie.find_in_tmdb(
        title: 'hacker',
        language: 'en'
      )
    end

    it 'returns movies from TMDb results' do
      movies = Movie.find_in_tmdb(
        title: 'Olympics',
        release_year: '2000',
        language: 'en'
      )

      expect(movies.length).to eq(2)
      expect(movies.first.title).to eq(
        'Sydney 2000 Olympics Opening Ceremony'
      )
      expect(movies.first.rating).to eq('R')
    end

    it 'does not save search results to the database' do
      expect {
        Movie.find_in_tmdb(title: 'Olympics', language: 'en')
      }.not_to change(Movie, :count)
    end
    
  end
end