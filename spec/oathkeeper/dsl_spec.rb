require 'spec_helper' 
require_relative './active_record_spec_helper'

describe OathKeeper::DSL do
  context 'basic stuff' do
  let(:block) { Proc.new {} }
  let(:dsl) { OathKeeper::DSL.new(&block) }

  describe 'definitiion' do
    it 'is not nil' do
      expect(dsl.definition).not_to be_nil
    end
  end

  describe '#parse' do
    let(:context) {nil} 
    it 'returns an empty hash with no context' do
      expect(dsl.parse!(context)).to be_empty
    end
  end
  end

  context 'activerecord' do
    describe 'dsl' do
      before do
        @author = Author.create({ name: 'justin' })
        @company = Company.create({ name: 'abc', owner_id: 5})
        @book = Book.create({ title: 'def', author: @author })
        @review = Reviews.create({ score: 1, review: 'sucks', book: @book, company: @company })
      end

      it 'saves single association' do
        @dsl = OathKeeper::DSL.new do
          associate :book, fields: [:title]
        end
        audit = @dsl.parse! @review
        expect(audit).to eq({ book: { title: @book.title }})
      end

      it 'saves multiple field single association' do
        @dsl = OathKeeper::DSL.new do
          associate :book, fields: [:title, :author_id]
        end
        audit = @dsl.parse! @review
        expect(audit).to eq({ book: { title: @book.title, author_id: @book.author_id }})
      end

      it 'save multiple fields multiple associations' do
        @dsl = OathKeeper::DSL.new do
          associate :book, fields: [:title, :author_id]
          associate :company, fields: [:name, :owner_id]
        end
        audit = @dsl.parse! @review
        expect(audit).to eq({ book: { title: @book.title, author_id: @book.author_id },
                              company: { name: @company.name, owner_id: @company.owner_id }})
      end

      it 'does not allow saving objects/instances' do
        @dsl = OathKeeper::DSL.new do
          associate :book, fields: [:author]
        end
        expect {
          @dsl.parse! @review
        }.to raise_error
      end

      it 'does not allow non-associations' do
        @review.stub(:opposite_book).and_return @book
        @dsl = OathKeeper::DSL.new do
          associate :opposite_book, fields: [:author]
        end

        expect {
          @dsl.parse! @review
        }.to raise_error
      end

      it 'allows non-associations' do
        @review.stub(:opposite_book).and_return @book
        @dsl = OathKeeper::DSL.new do
          associate :opposite_book, method: true, fields: [:author]
        end

        expect {
          @dsl.parse! @review
        }.not_to raise_error
      end
    end
  end
end
