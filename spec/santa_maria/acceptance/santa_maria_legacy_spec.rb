RSpec.describe 'santa maria legacy' do
  class SpyPresenter
    attr_reader :products, :variants

    def initialize
      @products = []
      @variants = []
    end

    def product(product)
      @products << product
    end

    def variant(variant)
      @variants << variant
    end
  end

  context do
    before do
      stub_request(:get, "https://api/api/products/eukdlx/fb1c568f-2c42-4b7d-8cac-a18500de96e8")
        .to_return(
          body: { packages: [] }.to_json,
          status: 200
        )

      stub_request(:get, "https://api/api/products/eukdlx")
        .to_return(
          body: response.to_json,
          status: 200
        )
    end

    context 'given one product' do
      let(:response) do
        response = {
          products: [{
                       globalId: 'fb1c568f-2c42-4b7d-8cac-a18500de96e8',
                       productType: 'Other'
                     }]
        }
      end

      it 'it able to extract those products' do
        use_case = SantaMaria::UseCase::FetchProducts.new(
          santa_maria: SantaMaria::Gateway::SantaMariaLegacy.new('https://api/')
        )

        spy_presenter = SpyPresenter.new
        use_case.execute(spy_presenter)

        expect(spy_presenter.products[0][:id]).to eq('fb1c568f-2c42-4b7d-8cac-a18500de96e8')
        expect(spy_presenter.products[0][:type]).to eq('Other')
        expect(spy_presenter.variants).to eq([])
      end
    end

    context 'given one product with a variant' do
      before do
        stub_request(:get, "https://api/api/products/eukdlx/192871-19291-39192-109283")
          .to_return(
            body: { packages: [{ articleNumber: '1111111' }] }.to_json,
            status: 200
          )
      end

      let(:response) do
        response = {
          products: [{
                       globalId: '192871-19291-39192-109283',
                       productType: 'Primer'
                     }]
        }
      end

      it 'it able to extract those products' do
        use_case = SantaMaria::UseCase::FetchProducts.new(
          santa_maria: SantaMaria::Gateway::SantaMariaLegacy.new('http://api/')
        )

        spy_presenter = SpyPresenter.new
        use_case.execute(spy_presenter)

        expect(spy_presenter.products[0][:id]).to eq('192871-19291-39192-109283')
        expect(spy_presenter.products[0][:type]).to eq('Primer')
        expect(spy_presenter.variants[0][:article_number]).to eq('1111111')
      end
    end

    context 'given two products with a variant' do
      before do
        stub_request(:get, "https://api/api/products/eukdlx/192871-19291-39192-109283")
          .to_return(
            body: { packages: [{ articleNumber: '1111111' }] }.to_json,
            status: 200
          )

        stub_request(:get, "https://api/api/products/eukdlx/192871-19291-39192-982910")
          .to_return(
            body: { packages: [{ articleNumber: '2222222' }, { articleNumber: '3333333' }] }.to_json,
            status: 200
          )
      end

      let(:response) do
        response = {
          products: [{
                       globalId: '192871-19291-39192-109283',
                       productType: 'Paint'
                     },
                     {
                       globalId: '192871-19291-39192-982910',
                       productType: 'Paint'
                     }]
        }
      end

      it 'is able to extract those products' do
        use_case = SantaMaria::UseCase::FetchProducts.new(
          santa_maria: SantaMaria::Gateway::SantaMariaLegacy.new('https://api/')
        )

        spy_presenter = SpyPresenter.new
        use_case.execute(spy_presenter)

        expect(spy_presenter.products[0][:id]).to eq('192871-19291-39192-109283')
        expect(spy_presenter.products[0][:type]).to eq('Paint')

        expect(spy_presenter.products[1][:id]).to eq('192871-19291-39192-982910')
        expect(spy_presenter.products[1][:type]).to eq('Paint')

        expect(spy_presenter.variants[0][:id]).to eq('192871-19291-39192-109283')
        expect(spy_presenter.variants[0][:article_number]).to eq('1111111')

        expect(spy_presenter.variants[1][:id]).to eq('192871-19291-39192-982910')
        expect(spy_presenter.variants[1][:article_number]).to eq('2222222')

        expect(spy_presenter.variants[2][:id]).to eq('192871-19291-39192-982910')
        expect(spy_presenter.variants[2][:article_number]).to eq('3333333')
      end
    end
  end
end
