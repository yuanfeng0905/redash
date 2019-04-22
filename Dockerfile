FROM node:10 as frontend-builder

WORKDIR /frontend
COPY package.json package-lock.json /frontend/
RUN npm install

COPY . /frontend
RUN npm run build

FROM redash/base:latest

# Controls whether to install extra dependencies needed for all data sources.
ARG skip_ds_deps

# We first copy only the requirements file, to avoid rebuilding on every file
# change.
COPY requirements.txt requirements_dev.txt requirements_all_ds.txt ./
RUN pip install -r requirements.txt -r requirements_dev.txt
RUN if [ "x$skip_ds_deps" = "x" ] ; then pip install -r requirements_all_ds.txt ; else echo "Skipping pip install -r requirements_all_ds.txt" ; fi

<<<<<<< HEAD
COPY . ./
RUN npm install -g cnpm --registry=https://registry.npm.taobao.org
RUN cnpm install && cnpm run bundle && cnpm run build && rm -rf node_modules
=======
COPY . /app
COPY --from=frontend-builder /frontend/client/dist /app/client/dist
>>>>>>> 10a6ccbbcdc0f553d5a3448950a2b9265f10eb96
RUN chown -R redash /app
USER redash

ENTRYPOINT ["/app/bin/docker-entrypoint"]
CMD ["server"]
