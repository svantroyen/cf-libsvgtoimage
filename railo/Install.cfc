<cfcomponent displayname="Install" output="false">
  <!--- Extension name --->
  <cfset variables.name = "cflibsvgtoimage" />

  <!--- Libraries --->
  <cfset variables.libraries = ["avalon-framework-api-4.3.1.jar", "avalon-framework-impl-4.3.1.jar", "batik-all-1.7.jar", "batik-anim-1.7.jar",
                                  "batik-awt-util-1.7.jar","batik-bridge-1.7.jar","batik-css-1.7.jar","batik-dom-1.7.jar","batik-ext-1.7.jar",
                                  "batik-gvt-1.7.jar","batik-parser-1.7.jar","batik-script-1.7.jar","batik-svg-dom-1.7.jar","batik-svggen-1.7.jar",
                                  "batik-transcoder-1.7.jar","batik-util-1.7.jar","batik-xml-1.7.jar","xml-apis-1.3.04.jar","xml-apis-ext-1.3.04.jar",
                                  "xmlgraphics-commons-2.1.jar"] />

  <!---
    Called from Railo to validate values
  --->
  <cffunction name="validate" access="public" returntype="void" output="false">
    <cfargument name="error" type="struct" />
    <cfargument name="path" type="string" />
    <cfargument name="config" type="struct" />
    <cfargument name="step" type="numeric" />

    <!--- Nothing to do --->
  </cffunction>

  <!---
    Called from Railo to install the extension
  --->
  <cffunction name="install" access="public" returntype="string" output="false">
    <cfargument name="error" type="struct" />
    <cfargument name="path" type="string" />
    <cfargument name="config" type="struct" />

    <!--- Defined local variables --->
    <cfset var serverPath = expandPath('{railo-web-directory}') />
    <cfset var dirPath = "" />
    <cfset var dirContent = "" />

    <!--- Update jars --->
    <cfset dirPath = arguments.path & "lib" />
    <cfdirectory action="list" directory="#dirPath#" type="file" filter="*.jar" name="dirContent">
    <cfloop query="dirContent">
      <cffile action="copy"
              source="#dirPath#/#dirContent.name#"
              destination="#serverPath#/lib/#dirContent.name#"
      />
    </cfloop>

    <!--- Add components --->
    <cfdirectory action="create" directory="#serverPath#/components/libsvgtoimage" />
    <cfset dirPath = arguments.path & "components" />
    <cfdirectory action="list" directory="#dirPath#" type="file" filter="*.cfc" name="dirContent">
    <cfloop query="dirContent">
      <cffile action="copy"
              source="#dirPath#/#dirContent.name#"
              destination="#serverPath#/components/libsvgtoimage/#dirContent.name#"
      />
    </cfloop>

    <!--- Add functions --->
    <cfset dirPath = arguments.path & "functions" />
    <cfdirectory action="list" directory="#dirPath#" type="file" filter="*.cfm" name="dirContent">
    <cfloop query="dirContent">
      <cffile action="copy"
              source="#dirPath#/#dirContent.name#"
              destination="#serverPath#/library/function/#dirContent.name#"
      />
    </cfloop>

    <cfreturn "#variables.name# has been successfully installed<br><br>" />
  </cffunction>

  <!---
    Called from Railo to update the extension
  --->
  <cffunction name="update" access="public" returntype="string" output="false">
    <cfargument name="error" type="struct" />
    <cfargument name="path" type="string" />
    <cfargument name="config" type="struct" />
    <cfargument name="previousConfig" type="struct" />

    <!--- Uninstall old version--->
    <cfset uninstall(arguments.path, arguments.previousConfig) />

    <!--- Install new version --->
    <cfset install(arguments.error, arguments.path, arguments.config) />
  </cffunction>

  <!---
    Called from Railo to uninstall the extension
  --->
  <cffunction name="uninstall" access="public" returntype="string" output="false">
    <cfargument name="path" type="string" />
    <cfargument name="config" type="struct" />

    <!--- Defined local variables --->
    <cfset var serverPath = expandPath('{railo-web-directory}') />
    <cfset var dirContent = "" />
    <cfset var library = "" />
    <cfset var funct = "" />
    <cfset var tag = "" />
    <cfset var i = 0 />
    <cfset var errors = arrayNew(1) />
    <cfset var message = "" />

    <!--- Remove the libraries --->
    <cfloop array="#variables.libraries#" index="i" item="library">
      <cfset removeFile("#serverPath#/lib/#library#", errors) />
    </cfloop>

    <!--- Remove the functions --->
    <cfdirectory action="list" directory="#serverPath#/library/function" filter="*libsvgtoimage*" name="dirContent" />
    <cfloop query="dirContent">
      <cfset removeFile("#serverPath#/library/function/#dirContent.name#", errors) />
    </cfloop>

    <!--- Remove the components --->
    <cfdirectory action="list" directory="#serverPath#/components/libsvgtoimage" name="dirContent" />
    <cfloop query="dirContent">
      <cfset removeFile("#serverPath#/components/libsvgtoimage/#dirContent.name#", errors) />
    </cfloop>
    <cfdirectory action="delete" directory="#serverPath#/components/libsvgtoimage" />

    <!--- Build return message --->
    <cfif arrayLen(errors)>
      <cfset message &= "The following files couldn't be deleted and should be removed manually:<br><br>" />
      <cfset message &= arrayTolist(errors, "<br>") />
      <cfset message &= "<br><br>" />
    </cfif>
    <cfset message &= "#variables.name# has been uninstalled<br><br>" />

    <cfreturn message />
  </cffunction>

  <!---
    Called from here to try to delete a file
  --->
  <cffunction name="removeFile" access="private" returntype="void" output="false">
    <cfargument name="filePath" type="string" />
    <cfargument name="errors" type="array" />

    <!--- Remove file --->
    <cftry>
      <cffile action="delete" file="#arguments.filePath#" />

      <!--- Handle errors --->
      <cfcatch type="any">
        <cfset arrayAppend(arguments.errors, arguments.filePath) />
      </cfcatch>
    </cftry>
  </cffunction>
</cfcomponent>