RSpec.describe RubocopDirector::Commands::GenerateConfig do
  subject { described_class.new.run }

  before do
    allow(File).to receive(:write)
  end

  context "when .rubocop_todo.yml exists" do
    let(:rubocop_todo_content) do
      {
        "Rails/SomeCop" => {
          "Exclude" => [
            "app/models/user.rb",
            "app/controller/user_controller.rb"
          ]
        }
      }
    end

    before do
      allow(YAML).to receive(:load_file).with(".rubocop_todo.yml").and_return(rubocop_todo_content)
    end

    it "returns success" do
      expect(subject).to be_success
      expect(subject.value!).to eq("Config generated")
    end

    it "creates file with config" do
      subject

      expect(File).to have_received(:write).with(
        ".rubocop-director.yml",
        "---\nupdate_weight: 1\ndefault_cop_weight: 1\nweights:\n  Rails/SomeCop: 1\n"
      )
    end
  end

  context "when .rubocop_todo.yml not exists" do
    before do
      allow(YAML).to receive(:load_file).with(".rubocop_todo.yml").and_raise(Errno::ENOENT)
    end

    it "returns failure" do
      expect(subject).to be_failure
      expect(subject.failure).to eq(".rubocop_todo.yml not found, generate it using `rubocop --regenerate-todo`")
    end

    it "not creates file with config" do
      subject

      expect(File).not_to have_received(:write)
    end
  end
end
