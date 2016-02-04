Code.require_file "../../test_helper.exs", __DIR__

defmodule Mix.Tasks.App.TreeTest do
  use MixTest.Case

  defmodule AppDepsSample do
    def project do
      [app: :test, version: "0.1.0", start_permanent: true]
    end

    def application do
      [applications: [:logger, :app_deps_sample]]
    end
  end

  @tag apps: [:test, :app_deps_sample, :app_deps2_sample, :app_deps3_sample, :app_deps4_sample]
  test "shows the application dependency tree", context do
    Mix.Project.push AppDepsSample

    in_tmp context.test, fn ->
      load_apps()
      Mix.Tasks.App.Tree.run([])

      assert_received {:mix_shell, :info, ["test"]}
      assert_received {:mix_shell, :info, [" `-- app_deps_sample"]}
      assert_received {:mix_shell, :info, ["    |-- app_deps2_sample"]}
      assert_received {:mix_shell, :info, ["    |  `-- app_deps4_sample"]}
      assert_received {:mix_shell, :info, ["    `-- app_deps3_sample"]}
    end
  end

  @tag apps: [:test, :app_deps_sample, :app_deps2_sample, :app_deps3_sample, :app_deps4_sample]
  test "shows the application dependency tree excluding application", context do
    Mix.Project.push AppDepsSample

    in_tmp context.test, fn ->
      load_apps()
      Mix.Tasks.App.Tree.run(["--exclude", "app_deps2_sample"])

      assert_received {:mix_shell, :info, ["test"]}
      assert_received {:mix_shell, :info, [" `-- app_deps_sample"]}
      refute_received {:mix_shell, :info, ["    |-- app_deps2_sample"]}
      refute_received {:mix_shell, :info, ["    |  `-- app_deps4_sample"]}
      assert_received {:mix_shell, :info, ["    `-- app_deps3_sample"]}
    end
  end

  @tag apps: [:test, :app_deps_sample, :app_deps2_sample, :app_deps3_sample, :app_deps4_sample]
  test "shows the application dependency tree excluding more applications", context do
    Mix.Project.push AppDepsSample

    in_tmp context.test, fn ->
      load_apps()
      Mix.Tasks.App.Tree.run(["--exclude", "app_deps4_sample", "--exclude", "app_deps3_sample"])

      assert_received {:mix_shell, :info, ["test"]}
      assert_received {:mix_shell, :info, [" `-- app_deps_sample"]}
      assert_received {:mix_shell, :info, ["    |-- app_deps2_sample"]}
      refute_received {:mix_shell, :info, ["    |  `-- app_deps4_sample"]}
      refute_received {:mix_shell, :info, ["    `-- app_deps3_sample"]}
    end
  end

  def load_apps() do
    :ok = :application.load({:application, :test, [vsn: '1.0.0', env: [], applications: [:app_deps_sample]]})
    :ok = :application.load({:application, :app_deps_sample, [vsn: '1.0.0', env: [], applications: [:app_deps2_sample, :app_deps3_sample]]})
    :ok = :application.load({:application, :app_deps2_sample, [vsn: '1.0.0', env: [], applications: [:app_deps4_sample]]})
    :ok = :application.load({:application, :app_deps3_sample, [vsn: '1.0.0', env: []]})
    :ok = :application.load({:application, :app_deps4_sample, [vsn: '1.0.0', env: []]})
  end
end