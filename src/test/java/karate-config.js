function fn() {
  var env = karate.env || 'local';
  var baseUrl = karate.properties['karate.baseUrl'] || 'http://localhost:3030';

  var config = {
    env: env,
    baseUrl: baseUrl
  };

  if (env === 'docker') {
    config.baseUrl = karate.properties['karate.baseUrl'] || 'http://host.docker.internal:3030';
  }

  karate.configure('connectTimeout', 5000);
  karate.configure('readTimeout', 10000);

  return config;
}
