require 'spec_helper'

RSpec.describe PolishGeeks::DevTools::Commands::RubocopRspec do
  subject { described_class.new }

  describe '#execute' do
    let(:path) { '/' }
    before do
      expect(ENV)
        .to receive(:[])
        .with('BUNDLE_GEMFILE')
        .and_return(path)
        .at_least(:once)
    end

    context 'when app config exists' do
      let(:cmd_expected) do
        "bundle exec rubocop -c #{path}.rubocop.yml #{PolishGeeks::DevTools.app_root} " \
        '--require rubocop-rspec'
      end

      before do
        expect(File)
          .to receive(:exist?)
          .and_return(true)
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with(cmd_expected)
      end

      it 'executes the command' do
        subject.execute
      end
    end

    context 'when app config does not exist' do
      let(:path) { Dir.pwd }
      let(:cmd_expected) do
        "bundle exec rubocop -c #{path}/config/rubocop.yml #{PolishGeeks::DevTools.app_root} " \
        '--require rubocop-rspec'
      end

      before do
        expect(PolishGeeks::DevTools)
          .to receive(:gem_root)
          .and_return(path)
        expect(File)
          .to receive(:exist?)
          .and_return(false)
        expect_any_instance_of(PolishGeeks::DevTools::Shell)
          .to receive(:execute)
          .with(cmd_expected)
      end

      it 'executes the command' do
        subject.execute
      end
    end
  end

  describe '#valid?' do
    context 'when offenses count is equal 0' do
      before do
        expect(subject)
          .to receive(:offenses_count)
          .and_return(0)
      end

      it 'returns true' do
        expect(subject.valid?).to eq true
      end
    end

    context 'when offenses count is different from 0' do
      before do
        expect(subject)
          .to receive(:offenses_count)
          .and_return(100)
      end

      it 'returns false' do
        expect(subject.valid?).to eq false
      end
    end
  end

  describe '#label' do
    context 'when we run rubocop' do
      before do
        expect(subject)
          .to receive(:files_count)
          .and_return(10)
        expect(subject)
          .to receive(:offenses_count)
          .and_return(5)
      end
      it 'returns the label' do
        expect(subject.label).to eq 'RubocopRspec (10 files, 5 offenses)'
      end
    end
  end

  describe '#files_count' do
    context 'when we count files' do
      before do
        subject.instance_variable_set(:@output, '10 files inspected')
      end

      it 'returns a proper value' do
        expect(subject.send(:files_count)).to eq 10
      end
    end
  end

  describe '#offenses_count' do
    context 'when we count offenses' do
      before do
        subject.instance_variable_set(:@output, '5 offenses detected')
      end

      it 'returns a proper value' do
        expect(subject.send(:offenses_count)).to eq 5
      end
    end
  end

  describe '.generator?' do
    it { expect(described_class.generator?).to eq false }
  end

  describe '.validator?' do
    it { expect(described_class.validator?).to eq true }
  end
end