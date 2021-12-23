require 'rbtv_sendeplan_bot/util'

describe RbtvSendeplanBot::Util do
  describe "display_title" do
    let(:subject) { described_class.display_title entry }

    describe "mit 3 Titel-Komponenten" do
      let(:entry) { { showTitle: "Show", title: "Title -", topic: "Topic" } }

      it "erstellt den Titel aus den ersten 2 Titel-Komponenten" do
        expect(subject).to eq "Show - Title"
      end
    end

    describe "mit showTitle ein Teil von title" do
      let(:entry) { { showTitle: "Show", title: "Show Title", topic: "Topic" } }

      it "liefert title und topic" do
        expect(subject).to eq "Show Title - Topic"
      end
    end

    describe "mit showTitle und topic ein Teil von title" do
      let(:entry) { { showTitle: "Show", title: "Show Title", topic: "Show" } }

      it "liefert title" do
        expect(subject).to eq "Show Title"
      end
    end

    describe "mit showTitle und topic ein Teil von title" do
      let(:entry) { { showTitle: "Show", title: "Title | Show", topic: "Topic" } }

      it "liefert title und topic" do
        expect(subject).to eq "Show - Title"
      end
    end
  end
end
