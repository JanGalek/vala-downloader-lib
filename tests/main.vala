using GLib;
using Gee;

int main (string[] args) {

    ValaFoundation.Testcases.BaseTest.saved_commands = new Gee.ArrayList<ValaFoundation.Testcases.TestCommand> ();
    Test.init (ref args);

    ValaFoundation.Testcases.register_test_suite<AppTests.ExampleTest> ();
    ValaFoundation.Testcases.register_test_suite<AppTests.DownloadAsyncLocalServerTest> ();
    ValaFoundation.Testcases.register_test_suite<AppTests.DownloadSyncLocalServerTest> ();
    ValaFoundation.Testcases.register_test_suite<AppTests.DownloadSyncNotFoundTest> ();
    ValaFoundation.Testcases.register_test_suite<AppTests.DownloadSyncInternalErrorTest> ();
    ValaFoundation.Testcases.register_test_suite<AppTests.QueueTest> ();


    return Test.run ();
}

