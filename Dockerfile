#Step 0: Choose base
FROM kshivaprasad/java:1.8
#Step 1 : Install the pre-requisite
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y p7zip \
    p7zip-full \
    unace \
    zip \
    unzip \
    bzip2

#Version numbers
ARG FIREFOX_VERSION=78.0.2
ARG CHROME_VERSION=83.0.4103.116
ARG CHROMDRIVER_VERSION=97.0.4692.71
ARG FIREFOXDRIVER_VERSION=0.29.0

#Step 2: Install Chrome
RUN apt-get install wget
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install ./google-chrome*.deb --yes
#Step 3: Install chromedriver for Selenium
RUN apt install wget -y
RUN wget https://chromedriver.storage.googleapis.com/97.0.4692.71/chromedriver_linux64.zip
RUN unzip chromedriver_linux64.zip -d /bin
RUN cd bin && chmod +x chromedriver
#Step 4 : Install firefox
RUN wget --no-verbose -O /tmp/firefox.tar.bz2 https://download-installer.cdn.mozilla.net/pub/firefox/releases/$FIREFOX_VERSION/linux-x86_64/en-US/firefox-$FIREFOX_VERSION.tar.bz2 \
  && bunzip2 /tmp/firefox.tar.bz2 \
  && tar xvf /tmp/firefox.tar \
  && mv /firefox /opt/firefox-$FIREFOX_VERSION \
  && ln -s /opt/firefox-$FIREFOX_VERSION/firefox /usr/bin/firefox
#Step 5: Install Geckodriver
RUN apt install wget -y
RUN wget https://github.com/mozilla/geckodriver/releases/download/v$FIREFOXDRIVER_VERSION/geckodriver-v$FIREFOXDRIVER_VERSION-linux64.tar.gz
RUN tar -xvzf geckodriver-v0.29.0-linux64.tar.gz
RUN chmod +x geckodriver
RUN mv geckodriver /bin
RUN apt install firefox -y
RUN export MOZ_HEADLESS=1
#Step 6: Install Maven
# 1- Define Maven version
ARG MAVEN_VERSION=3.6.3
# 2- Define a constant with the working directory
ARG USER_HOME_DIR="/root"

# 3- Define the SHA key to validate the maven download
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0

# 4- Define the URL where maven can be downloaded from
ARG BASE_URL=http://apache.mirrors.tds.net/maven/maven-3/${MAVEN_VERSION}/binaries

# 5- Create the directories, download maven, validate the download, install it, remove downloaded file and set links
RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && echo "Downlaoding maven" \
  && curl -fsSL -o /tmp/apache-maven.tar.gz ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
  \
  && echo "Checking download hash" \
  && echo "${SHA}  /tmp/apache-maven.tar.gz" | sha512sum -c - \
  \
  && echo "Unziping maven" \
  && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven --strip-components=1 \
  \
  && echo "Cleaning and setting links" \
  && rm -f /tmp/apache-maven.tar.gz \
  && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn

# 6- Define environmental variables required by Maven, like Maven_Home directory and where the maven repo is located
ENV MAVEN_HOME /usr/share/maven
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
#Step 7: Copy our project
COPY . /app
#Making our working directory as /app
WORKDIR /app
