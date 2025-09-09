import pytest
from dbt.cli.main import dbtRunner


def pytest_sessionstart(session):
    #this code builds the dbt project even when I just want tests collected not run
    #This could also be done with a test fixture but this is a smaller rewrite
    if session.config.option.collectonly:
        print("Skipping DBT build: collect-only mode")
        return

    print("building DBT project")
    build_args = [
        "build",
        "--project-dir",
        "provider_pipeline",
        "--profiles-dir",
        "test_interview/dbt_profile",
    ]
    dbt = dbtRunner()
    try:
        dbtRunnerResult = dbt.invoke(build_args)
    except Exception as e:
        print(str(e))
        pytest.exit('Unable to build dbt project')
    for r in dbtRunnerResult.result:
        if r.status != 'success':
            pytest.exit('Unable to build dbt project')
