FROM store/intersystems/iris-community:2019.3.0.309.0

COPY ./ ./

ARG NAMESPACE="AnalyzeThis"
RUN iris start $ISC_PACKAGE_INSTANCENAME quietly EmergencyId=sys,sys && \
    /bin/echo -e "sys\nsys\n" \
            " Do ##class(Security.Users).UnExpireUserPasswords(\"*\")\n" \
            " Do ##class(Security.Users).AddRoles(\"admin\", \"%ALL\")\n" \
            " Do ##class(Security.System).Get(,.p)\n" \
            " Set p(\"AutheEnabled\")=\$zb(p(\"AutheEnabled\"),16,7)\n" \
            " Do ##class(Security.System).Modify(,.p)\n" \
            " Do \$system.OBJ.Load(\"/home/irisowner/AnalyzeThis/Installer.cls\",\"ck\")\n" \
			" Set sc = ##class(AnalyzeThis.Installer).RunFullInstaller(\"/home/irisowner/\")\n" \
			" If 'sc do \$zu(4, \$JOB, 1)\n" \
            " zn \"%sys\"" \
            " write \"Create web application ...\",!" \
            " set webName = \"/csp/AnalyzeThis\"" \
            " set webProperties(\"NameSpace\") = \"${NAMESPACE}\"" \
            " set webProperties(\"Enabled\") = 1" \
            " set webProperties(\"IsNameSpaceDefault\") = 1" \
            " set webProperties(\"CSPZENEnabled\") = 1" \
            " set webProperties(\"AutheEnabled\") = 32" \
            " set webProperties(\"iKnowEnabled\") = 1" \
            " set webProperties(\"DeepSeeEnabled\") = 1" \
            " set status = ##class(Security.Applications).Create(webName, .webProperties)" \
            " write:'status \$system.Status.DisplayError(status)" \
            " write \"Web application \"\"\"_webName_\"\"\" was created!\",!" \
            " halt" \
    | iris session $ISC_PACKAGE_INSTANCENAME && \
    /bin/echo -e "sys\nsys\n" \
    | iris stop $ISC_PACKAGE_INSTANCENAME quietly

CMD [ "-l", "/usr/irissys/mgr/messages.log" ] 