import * as shell from "shelljs";

// Copy all the view templates
shell.cp( "-R", "src/views", "dist/" );

// Copy all the public files
shell.cp( "-R", "src/public", "dist/" );