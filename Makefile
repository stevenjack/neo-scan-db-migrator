BRANCH ?= "master"
GO_BUILDER_IMAGE ?= "vidsyhq/go-builder"
PATH_BASE ?= "/go/src/github.com/stevenjack"
REPONAME ?= "neo-scan-db-migrator"
ORG ?= "smaj"
VERSION ?= $(shell cat ./VERSION)

build-binary:
	@docker run \
	-v "${CURDIR}":${PATH_BASE}/${REPONAME} \
	-w ${PATH_BASE}/${REPONAME} \
	${GO_BUILDER_IMAGE}

build-image:
	@docker build -t ${ORG}/${REPONAME} --build-arg VERSION=${VERSION} .

check-version:
	@echo "=> Checking if VERSION exists as Git tag..."
	(! git rev-list ${VERSION})

docker-login:
	@docker login -e ${DOCKER_EMAIL} -u ${DOCKER_USER} -p ${DOCKER_PASS}

push-tag:
	@echo "=> New tag version: ${VERSION}"
	git checkout ${BRANCH}
	git pull origin ${BRANCH}
	git tag ${VERSION}
	git push origin ${BRANCH} --tags

push-to-registry:
	@docker login -e ${DOCKER_EMAIL} -u ${DOCKER_USER} -p ${DOCKER_PASS}
	@docker tag ${ORG}/${REPONAME}:latest ${ORG}/${REPONAME}:${CIRCLE_TAG}
	@docker push ${ORG}/${REPONAME}:${CIRCLE_TAG}
	@docker push ${ORG}/${REPONAME}

run:
	@go build -i -ldflags "-X main.Version=${VERSION}-dev -X main.BuildTime=17/01/2017T14:12:35+0000"
	@./${REPONAME}
