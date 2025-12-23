package com.voting.system;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@SpringBootApplication
public class VotingSystemApplication {

	public static void main(String[] args) {
		SpringApplication.run(VotingSystemApplication.class, args);
	}

	@org.springframework.context.annotation.Bean
	public org.springframework.boot.CommandLineRunner resetTestVoter(
			com.voting.system.repository.VoterRepository repository) {
		return args -> {
			repository.findById("aadhaar_123").ifPresent(voter -> {
				voter.setHasVoted(false);
				repository.save(voter);
				System.out.println("TEST DATA RESET: Voter 'aadhaar_123' has_voted set to FALSE.");
			});
		};
	}
}
