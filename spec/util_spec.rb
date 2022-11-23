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

      describe "mit Grossbuchstaben" do
        let(:entry) {
          {
            showTitle: "Show Title",
            title: "Some description | Somebody does something! | SHOW TITLE",
            topic: "More description | Somebody does something!",
          }
        }

        it "ignoriert unterschiedliche Gross- und Kleinbuchstaben" do
          expect(subject).to eq "Show Title - Some description | Somebody does something!"
        end
      end
    end

    describe "mit showTitle und topic ein Teil von title" do
      let(:entry) { { showTitle: "Event", title: "Title | A SHOW 1/3", topic: "A show #1" } }

      it "liefert title und topic" do
        expect(subject).to eq entry[:title]
      end
    end

    describe "mit showTitle ein Teil von title und title mit |" do
      let(:entry) { { showTitle: "Serie", title: "| Serie", topic: "Topic" } }

      it "liefert showTitle und topic" do
        expect(subject).to eq "Serie - Topic"
      end
    end

    describe 'mit Teilen in title dupliziert' do
      let(:entry) {
        {
          :title=>"Title | Something else #123 | Something Else #123",
          :topic=>"Topic",
          :showTitle=>"Show Title",
        }
      }

      it "liefert showTitle und topic" do
        expect(subject).to eq "Show Title - Title | Something else #123"
      end
    end
  end
end
