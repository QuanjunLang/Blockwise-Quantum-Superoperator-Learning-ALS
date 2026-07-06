function pe = setup_python(pythonExecutable)
%SETUP_PYTHON Configure MATLAB to use the project Python environment.
%
%   PE = SETUP_PYTHON() reads the Python executable from the
%   QUANTUM_ALS_PYTHON environment variable. If that variable is not set,
%   it searches the active Conda installation for the project environment.
%
%   PE = SETUP_PYTHON(PYTHONEXECUTABLE) uses the explicitly supplied
%   Python executable.

environmentName = "blockwise-quantum-superoperator-learning-als";

if nargin < 1 || strlength(string(pythonExecutable)) == 0
    pythonExecutable = getenv("QUANTUM_ALS_PYTHON");
end

if strlength(string(pythonExecutable)) == 0
    condaPrefix = getenv("CONDA_PREFIX");
    if strlength(string(condaPrefix)) > 0
        [~, activeEnvironment] = fileparts(condaPrefix);
        if string(activeEnvironment) == environmentName
            pythonExecutable = localPythonExecutable(condaPrefix);
        else
            pythonExecutable = localPythonExecutable( ...
                fullfile(condaPrefix, "envs", environmentName));
        end
    end
end

if strlength(string(pythonExecutable)) == 0
    [condaStatus, condaBase] = system("conda info --base");
    if condaStatus == 0
        pythonExecutable = localPythonExecutable( ...
            fullfile(strtrim(string(condaBase)), "envs", environmentName));
    end
end

if strlength(string(pythonExecutable)) == 0 || ~isfile(pythonExecutable)
    homeFolder = string(getenv("HOME"));
    if ispc
        homeFolder = string(getenv("USERPROFILE"));
    end

    candidatePrefixes = [
        fullfile(homeFolder, "miniconda3", "envs", environmentName)
        fullfile(homeFolder, "anaconda3", "envs", environmentName)
        fullfile("/opt/anaconda3", "envs", environmentName)
        fullfile("/opt/miniconda3", "envs", environmentName)
    ];

    for candidatePrefix = candidatePrefixes'
        candidatePython = localPythonExecutable(candidatePrefix);
        if isfile(candidatePython)
            pythonExecutable = candidatePython;
            break
        end
    end
end

if strlength(string(pythonExecutable)) == 0
    error("QuantumALS:PythonNotConfigured", ...
        "Python is not configured. Set QUANTUM_ALS_PYTHON to the project environment's Python executable, or pass that path directly to setup_python.");
end

pythonExecutable = string(pythonExecutable);
if ~isfile(pythonExecutable)
    error("QuantumALS:PythonNotFound", ...
        "Python executable not found: %s", pythonExecutable);
end

pe = pyenv;
if pe.Status == "Loaded" && string(pe.Executable) ~= pythonExecutable
    if pe.ExecutionMode == "OutOfProcess"
        terminate(pe);
    else
        error("QuantumALS:PythonAlreadyLoaded", ...
            "MATLAB has already loaded a different in-process Python. Restart MATLAB, then call setup_python before using Python.");
    end
end

pe = pyenv(Version=pythonExecutable, ExecutionMode="OutOfProcess");
end

function pythonExecutable = localPythonExecutable(environmentPrefix)
if ispc
    pythonExecutable = fullfile(environmentPrefix, "python.exe");
else
    pythonExecutable = fullfile(environmentPrefix, "bin", "python");
end
end
