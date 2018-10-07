package no.eritec.demo.springjdbc.config;

import org.flywaydb.core.Flyway;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.flyway.FlywayMigrationStrategy;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;
import org.springframework.core.env.Environment;

@Configuration
@PropertySource(value = { "classpath:application.properties" })
public class FlywayConfig {
	
   @Autowired
   private Environment env;
	
   static Logger logger = LoggerFactory.getLogger(FlywayConfig.class);
 
   boolean clean = true;
    
   @Bean
   public FlywayMigrationStrategy cleanMigrateStrategy() {

      FlywayMigrationStrategy strategy = new FlywayMigrationStrategy() {

            @Override
            public void migrate(Flyway flyway) {
        	
               if (Boolean.parseBoolean(env.getProperty("flyway-clean-on-migrate","true"))) {
                  logger.info("Cleaning DB with Flyway");
                  flyway.clean();
               } else {
                  logger.info("Skipping cleaning (FlywayDB)");
               }

               flyway.migrate();
            }
         };

      return strategy;
   }

   public boolean isClean() {
      return clean;
   }

   public void setClean(boolean clean) {
      this.clean = clean;
   }

}