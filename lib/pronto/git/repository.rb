module Pronto
  module Git
    class Repository
      def initialize(path)
        @repo = Rugged::Repository.new(path)
      end

      def remotes
        @repo.remotes.map { |remote| Remote.new(remote) }
      end

      def diff(commit)
        merge_base = merge_base(commit)
        patches = @repo.diff(merge_base, head)
        Patches.new(self, merge_base, patches)
      end

      def show_commit(sha)
        return [] unless sha

        commit = @repo.lookup(sha)
        return [] if commit.parents.count != 1

        # TODO: Rugged does not seem to support diffing against multiple parents
        diff = commit.diff(reverse: true)
        return [] if diff.nil?

        Patches.new(self, sha, diff.patches)
      end

      def path
        @repo.path
      end

      def rugged
        @repo
      end

      private

      def merge_base(commit)
        @repo.merge_base(commit, head)
      end

      def head
        @repo.head.target
      end
    end
  end
end
