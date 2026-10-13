# 복지이음 (bokji-ieum)

시흥시 744개 복지자원을 로그인 없이 1분 만에 매칭해 주는 웹 서비스. Spring MVC 5.3(비-Boot, web.xml) + MyBatis + MySQL 8 + JSP/JSTL, Tomcat 9(war) 구성이며, 로컬 기동은 `./mvnw cargo:run` 한 줄, DB는 `docker compose up -d`로 띄운다. 자세한 셋업은 [SETUP.md](SETUP.md) 참고.
