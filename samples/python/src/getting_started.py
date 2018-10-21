import time

import json
import logging
from typing import Optional

import requests

import string
import random
import ctypes
import asyncio

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

_host = "http://172.31.182.113:8080"
# dids
agency = "PFR1KHahcYRtoJJGSAQYBJ"
gov   = ""
faber = ""
acme  = ""
thrift= ""


async def run():
    logger.info("Getting started -> started")
    logger.info("\"Agency\" -> Create gov, faber, acme, thrift and alice")

    gov   = event_send(agency,"agency","CREATE",{"name":"gov"    }).json()["directives"][0]["options"]["pico"]["eci"]
    faber = event_send(agency,"agency","CREATE",{"name":"faber"  }).json()["directives"][0]["options"]["pico"]["eci"]
    acme  = event_send(agency,"agency","CREATE",{"name":"acme"   }).json()["directives"][0]["options"]["pico"]["eci"]
    thrift= event_send(agency,"agency","CREATE",{"name":"thrift" }).json()["directives"][0]["options"]["pico"]["eci"]
    alice = event_send(agency,"agency","CREATE",{"name":"alice"  }).json()["directives"][0]["options"]["pico"]["eci"]

    input("Agents have been created, feel free to check, Press Enter to continue...")

    logger.info("\ngov:{} \n faber:{} \n acme:{} \n thrift:{}\n alice:{}\n".format(gov,faber,acme,thrift,alice))
    
    logger.info("\"Sovrin Steward\" -> Create and store in Wallet DID from seed")

    event_send(gov,"agent","create_did",{"seed":"000000000000000000000000Steward1","meta_data":"steward_did"})# this generates the same keys used in the genisis file 
    input("Steward did generated, Press Enter to continue...")
    
    logger.info("==============================")
    logger.info("===      Subscriptions      ==")
    logger.info("------------------------------")


    logger.info("==============================")
    logger.info("=== Getting Trust Anchor permissions for Faber, Acme, Thrift and Government using steward did ==")
    logger.info("------------------------------")

    logger.info("==============================")
    logger.info("== Creating Government Verinym ==")
    logger.info("------------------------------")

    did = event_send(gov,"agent","create_did",{"meta_data":"TRUST_ANCHOR"})
    logger.info(did)
    
    did = event_send(gov,"agent","nym",{"seed":"000000000000000000000000Steward1","meta_data":"TRUST_ANCHOR"})
    logger.info(did)
    # get_verinym(pool_handle, "Sovrin Steward", steward_wallet[0], steward_did,
    #                                    "Government", government_wallet[0],
    #                                    'TRUST_ANCHOR')
    input("Press Enter to continue...")

    logger.info("==============================")
    logger.info("== Creating Faber Verinym  ==")
    logger.info("------------------------------")

    # get_verinym(pool_handle, "Sovrin Steward", steward_wallet[0], steward_did,
    #                              "Faber", faber_wallet[0], 'TRUST_ANCHOR')

    logger.info("==============================")
    logger.info("== Creating Acme Verinym  ==")
    logger.info("------------------------------")

    # await get_verinym(pool_handle, "Sovrin Steward", steward_wallet[0], steward_did,
    #                             "Acme", acme_wallet[0], 'TRUST_ANCHOR')

    logger.info("==============================")
    logger.info("== Creating Thrift Verinym  ==")
    logger.info("------------------------------")

    # get_verinym(pool_handle, "Sovrin Steward", steward_wallet[0], steward_did,
    #                               "Thrift", thrift_wallet[0], 'TRUST_ANCHOR')

    logger.info("==============================")
    logger.info("=== Credential Schemas Setup ==")
    logger.info("------------------------------")

    logger.info("\"Government\" -> Create \"Job-Certificate\" Schema")
    
    #anoncreds.issuer_create_schema(government_did, 'Job-Certificate', '0.2',
    #                                         json.dumps(['first_name', 'last_name', 'salary', 'employee_status',
    #                                                     'experience']))

    #logger.info("\"Government\" -> Send \"Job-Certificate\" Schema to Ledger")
    # send_schema(pool_handle, government_wallet[0], government_did, job_certificate_schema)

    logger.info("\"Government\" -> Create \"Transcript\" Schema")
    # anoncreds.issuer_create_schema(government_did, 'Transcript', '1.2',
    #                                         json.dumps(['first_name', 'last_name', 'degree', 'status',
    #                                                     'year', 'average', 'ssn']))
    #logger.info("\"Government\" -> Send \"Transcript\" Schema to Ledger")
    # send_schema(pool_handle, government_wallet[0], government_did, transcript_schema)

    logger.info("==============================")
    logger.info("=== Faber Credential Definition Setup ==")
    logger.info("------------------------------")

    #logger.info("\"Faber\" -> Get \"Transcript\" Schema from Ledger")
    logger.info("\"Faber\" -> Create and store in Wallet \"Faber Transcript\" Credential Definition")
    #anoncreds.issuer_create_and_store_credential_def(faber_wallet[0], faber_did, transcript_schema,
    #                                                           'TAG1', 'CL', '{"support_revocation": false}')

    #logger.info("\"Faber\" -> Send  \"Faber Transcript\" Credential Definition to Ledger")

    logger.info("==============================")
    logger.info("=== Acme Credential Definition Setup ==")
    logger.info("------------------------------")

    logger.info("\"Acme\" -> Get from Ledger \"Job-Certificate\" Schema")
    #await get_schema(pool_handle, acme_did, job_certificate_schema_id)

    logger.info("\"Acme\" -> Create and store in Wallet \"Acme Job-Certificate\" Credential Definition")
    # anoncreds.issuer_create_and_store_credential_def(acme_wallet[0], acme_did, job_certificate_schema,
    #                                                           'TAG1', 'CL', '{"support_revocation": false}')

    #logger.info("\"Acme\" -> Send \"Acme Job-Certificate\" Credential Definition to Ledger")
    # send_cred_def(pool_handle, acme_wallet[0], acme_did, acme_job_certificate_cred_def_json)

    logger.info("==============================")
    logger.info("=== Getting Transcript with Faber ==")
    logger.info("==============================")
    logger.info("== Alice Faber - Onboarding (subscription) ==")
    logger.info("------------------------------")

    # await did.create_and_store_my_did(alice_wallet[0], "{}") # did for get_cred_def_request

    logger.info("==============================")
    logger.info("== Getting Transcript with Faber - Getting Transcript Credential ==")
    logger.info("------------------------------")

    '''logger.info("\"Faber\" -> Create \"Transcript\" Credential Offer for Alice")
    transcript_cred_offer_json = \
        await anoncreds.issuer_create_credential_offer(faber_wallet[0], faber_transcript_cred_def_id)

    logger.info("\"Faber\" -> Send \"Transcript\" Credential Offer to Alice")

    transcript_cred_offer = json.loads(transcript_cred_offer_json)

    logger.info("\"Alice\" -> Create and store \"Alice\" Master Secret in Wallet")
    alice_master_secret_id = await anoncreds.prover_create_master_secret(alice_wallet[0], None)

    logger.info("\"Alice\" -> Get \"Faber Transcript\" Credential Definition from Ledger")
    #----------------------------------------------------------------------------------------------------------------------------------------------------
    # prover attempt to get cred_def from ledger 
    #----------------------------------------------------------------------------------------------------------------------------------------------------
    get_cred_def_request = await ledger.build_get_cred_def_request(alice_faber_did , transcript_cred_offer['cred_def_id'])
    logger.info("cred request" + json.dumps(get_cred_def_request) )
    get_cred_def_response = await ledger.submit_request(pool_handle, get_cred_def_request)
    #logger.info("cred request response" + json.dumps(get_cred_def_response) )
    (faber_transcript_cred_def_id, faber_transcript_cred_def) = \
        await ledger.parse_get_cred_def_response(get_cred_def_response)
    #----------------------------------------------------------------------------------------------------------------------------------------------------
    #----------------------------------------------------------------------------------------------------------------------------------------------------

    logger.info("\"Alice\" -> Create \"Transcript\" Credential Request for Faber")
    (transcript_cred_request_json, transcript_cred_request_metadata_json) = \
        await anoncreds.prover_create_credential_req(alice_wallet[0], alice_faber_did,
                                                     transcript_cred_offer_json,
                                                     faber_transcript_cred_def, alice_master_secret_id)

    logger.info("\"Alice\" -> Send   \"Transcript\" Credential Request to Faber")
    
    logger.info("\"Faber\" -> Create \"Transcript\" Credential for Alice")
    transcript_cred_values = json.dumps({
        "first_name": {"raw": "Alice", "encoded": "1139481716457488690172217916278103335"},
        "last_name": {"raw": "Garcia", "encoded": "5321642780241790123587902456789123452"},
        "degree": {"raw": "Bachelor of Science, Marketing", "encoded": "12434523576212321"},
        "status": {"raw": "graduated", "encoded": "2213454313412354"},
        "ssn": {"raw": "123-45-6789", "encoded": "3124141231422543541"},
        "year": {"raw": "2015", "encoded": "2015"},
        "average": {"raw": "5", "encoded": "5"}
    })

    transcript_cred_json, _, _ = \
        await anoncreds.issuer_create_credential(faber_wallet[0], transcript_cred_offer_json,
                                                 transcript_cred_request_json, 
                                                 transcript_cred_values, None, None)

    logger.info("\"Faber\" -> Send \"Transcript\" Credential to Alice")

    logger.info("\"Alice\" -> Store \"Transcript\" Credential from Faber")
    await anoncreds.prover_store_credential(alice_wallet[0], None, transcript_cred_request_metadata_json,
                                            transcript_cred_json, faber_transcript_cred_def, None)

    logger.info("==============================")
    logger.info("=== Apply for the job with Acme ==")
    logger.info("==============================")
    logger.info("== Apply for the job with Acme - Onboarding ==")
    logger.info("------------------------------")

    ( alice_acme_did, _ ) = await did.create_and_store_my_did(alice_wallet[0], "{}") # did for cred

    logger.info("==============================")
    logger.info("== Apply for the job with Acme - Transcript proving ==")
    logger.info("------------------------------")

    logger.info("\"Acme\" -> Create \"Job-Application\" Proof Request")
    job_application_proof_request_json = json.dumps({
        'nonce': '1432422343242122312411212',
        'name': 'Job-Application',
        'version': '0.1',
        'requested_attributes': {
            'attr1_referent': {
                'name': 'first_name'
            },
            'attr2_referent': {
                'name': 'last_name'
            },
            'attr3_referent': {
                'name': 'degree',
                'restrictions': [{'cred_def_id': faber_transcript_cred_def_id}]
            },
            'attr4_referent': {
                'name': 'status',
                'restrictions': [{'cred_def_id': faber_transcript_cred_def_id}]
            },
            'attr5_referent': {
                'name': 'ssn',
                'restrictions': [{'cred_def_id': faber_transcript_cred_def_id}]
            },
            'attr6_referent': {
                'name': 'phone_number'
            }
        },
        'requested_predicates': {
            'predicate1_referent': {
                'name': 'average',
                'p_type': '>=',
                'p_value': 4,
                'restrictions': [{'cred_def_id': faber_transcript_cred_def_id}]
            }
        }
    })

    logger.info("\"Acme\" -> Send \"Job-Application\" Proof Request to Alice")

    logger.info("\"Alice\" -> Get credentials for \"Job-Application\" Proof Request")

    search_for_job_application_proof_request = \
        await anoncreds.prover_search_credentials_for_proof_req(alice_wallet[0],
                                                                job_application_proof_request_json, None)

    cred_for_attr1 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr1_referent')
    cred_for_attr2 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr2_referent')
    cred_for_attr3 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr3_referent')
    cred_for_attr4 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr4_referent')
    cred_for_attr5 = await get_credential_for_referent(search_for_job_application_proof_request, 'attr5_referent')
    cred_for_predicate1 = \
        await get_credential_for_referent(search_for_job_application_proof_request, 'predicate1_referent')

    await anoncreds.prover_close_credentials_search_for_proof_req(search_for_job_application_proof_request)

    creds_for_job_application_proof = {cred_for_attr1['referent']: cred_for_attr1,
                                       cred_for_attr2['referent']: cred_for_attr2,
                                       cred_for_attr3['referent']: cred_for_attr3,
                                       cred_for_attr4['referent']: cred_for_attr4,
                                       cred_for_attr5['referent']: cred_for_attr5,
                                       cred_for_predicate1['referent']: cred_for_predicate1}

    schemas_json, cred_defs_json, revoc_states_json = \
        await prover_get_entities_from_ledger(pool_handle, alice_faber_did, creds_for_job_application_proof, 'Alice')

    logger.info("\"Alice\" -> Create \"Job-Application\" Proof")
    job_application_requested_creds_json = json.dumps({
        'self_attested_attributes': {
            'attr1_referent': 'Alice',
            'attr2_referent': 'Garcia',
            'attr6_referent': '123-45-6789'
        },
        'requested_attributes': {
            'attr3_referent': {'cred_id': cred_for_attr3['referent'], 'revealed': True},
            'attr4_referent': {'cred_id': cred_for_attr4['referent'], 'revealed': True},
            'attr5_referent': {'cred_id': cred_for_attr5['referent'], 'revealed': True},
        },
        'requested_predicates': {'predicate1_referent': {'cred_id': cred_for_predicate1['referent']}}
    })

    job_application_proof_json = \
        await anoncreds.prover_create_proof(alice_wallet[0], job_application_proof_request_json,
                                            job_application_requested_creds_json, alice_master_secret_id,
                                            schemas_json, cred_defs_json, revoc_states_json)

    logger.info("\"Alice\" -> Send \"Job-Application\" Proof to Acme")

    decrypted_job_application_proof = json.loads(job_application_proof_json)

    schemas_json, cred_defs_json, revoc_ref_defs_json, revoc_regs_json = \
        await verifier_get_entities_from_ledger(pool_handle, acme_did,
                                                decrypted_job_application_proof['identifiers'], 'Acme')

    logger.info("\"Acme\" -> Verify \"Job-Application\" Proof from Alice")
    assert 'Bachelor of Science, Marketing' == \
           decrypted_job_application_proof['requested_proof']['revealed_attrs']['attr3_referent']['raw']
    assert 'graduated' == \
           decrypted_job_application_proof['requested_proof']['revealed_attrs']['attr4_referent']['raw']
    assert '123-45-6789' == \
           decrypted_job_application_proof['requested_proof']['revealed_attrs']['attr5_referent']['raw']

    assert 'Alice' == decrypted_job_application_proof['requested_proof']['self_attested_attrs']['attr1_referent']
    assert 'Garcia' == decrypted_job_application_proof['requested_proof']['self_attested_attrs']['attr2_referent']
    assert '123-45-6789' == decrypted_job_application_proof['requested_proof']['self_attested_attrs']['attr6_referent']

    assert await anoncreds.verifier_verify_proof(job_application_proof_request_json,
                                                 job_application_proof_json,
                                                 schemas_json, cred_defs_json, revoc_ref_defs_json, revoc_regs_json)

    logger.info("==============================")
    logger.info("== Apply for the job with Acme - Getting Job-Certificate Credential ==")
    logger.info("------------------------------")

    logger.info("\"Acme\" -> Create \"Job-Certificate\" Credential Offer for Alice")
    job_certificate_cred_offer_json = \
        await anoncreds.issuer_create_credential_offer(acme_wallet[0], acme_job_certificate_cred_def_id)

    logger.info("\"Acme\" -> Send \"Job-Certificate\" Credential Offer to Alice")

    authdecrypted_job_certificate_cred_offer = json.loads(job_certificate_cred_offer_json)
    logger.info("\"Alice\" -> Get \"Acme Job-Certificate\" Credential Definition from Ledger")
    (_, acme_job_certificate_cred_def) = \
        await get_cred_def(pool_handle, alice_acme_did, authdecrypted_job_certificate_cred_offer['cred_def_id'])

    logger.info("\"Alice\" -> Create and store in Wallet \"Job-Certificate\" Credential Request for Acme")
    (job_certificate_cred_request_json, job_certificate_cred_request_metadata_json) = \
        await anoncreds.prover_create_credential_req(alice_wallet[0], alice_acme_did,
                                                     job_certificate_cred_offer_json,
                                                     acme_job_certificate_cred_def, alice_master_secret_id)

    logger.info("\"Alice\" -> Send \"Job-Certificate\" Credential Request to Acme")

    logger.info("\"Acme\" -> Create \"Job-Certificate\" Credential for Alice")
    alice_job_certificate_cred_values_json = json.dumps({
        "first_name": {"raw": "Alice", "encoded": "245712572474217942457235975012103335"},
        "last_name": {"raw": "Garcia", "encoded": "312643218496194691632153761283356127"},
        "employee_status": {"raw": "Permanent", "encoded": "2143135425425143112321314321"},
        "salary": {"raw": "2400", "encoded": "2400"},
        "experience": {"raw": "10", "encoded": "10"}
    })

    job_certificate_cred_json, _, _ = \
        await anoncreds.issuer_create_credential(acme_wallet[0], job_certificate_cred_offer_json,
                                                 job_certificate_cred_request_json,
                                                 alice_job_certificate_cred_values_json, None, None)

    logger.info("\"Acme\" -> Send \"Job-Certificate\" Credential to Alice")

    logger.info("\"Alice\" -> Store \"Job-Certificate\" Credential")
    await anoncreds.prover_store_credential(alice_wallet[0], None, job_certificate_cred_request_metadata_json,
                                            job_certificate_cred_json,
                                            acme_job_certificate_cred_def_json, None)

    logger.info("==============================")
    logger.info("=== Apply for the loan with Thrift ==")
    logger.info("==============================")
    logger.info("== Apply for the loan with Thrift - Onboarding ==")
    logger.info("------------------------------")
    
    ( alice_thrift_did, _ ) = await did.create_and_store_my_did(alice_wallet[0], "{}")

    logger.info("==============================")
    logger.info("== Apply for the loan with Thrift - Job-Certificate proving  ==")
    logger.info("------------------------------")

    logger.info("\"Thrift\" -> Create \"Loan-Application-Basic\" Proof Request")
    apply_loan_proof_request_json = json.dumps({
        'nonce': '123432421212',
        'name': 'Loan-Application-Basic',
        'version': '0.1',
        'requested_attributes': {
            'attr1_referent': {
                'name': 'employee_status',
                'restrictions': [{'cred_def_id': acme_job_certificate_cred_def_id}]
            }
        },
        'requested_predicates': {
            'predicate1_referent': {
                'name': 'salary',
                'p_type': '>=',
                'p_value': 2000,
                'restrictions': [{'cred_def_id': acme_job_certificate_cred_def_id}]
            },
            'predicate2_referent': {
                'name': 'experience',
                'p_type': '>=',
                'p_value': 1,
                'restrictions': [{'cred_def_id': acme_job_certificate_cred_def_id}]
            }
        }
    })

    logger.info("\"Thrift\" -> Send \"Loan-Application-Basic\" Proof Request to Alice")

    logger.info("\"Alice\" -> Get credentials for \"Loan-Application-Basic\" Proof Request")

    search_for_apply_loan_proof_request = \
        await anoncreds.prover_search_credentials_for_proof_req(alice_wallet[0],
                                                                apply_loan_proof_request_json, None)

    cred_for_attr1 = await get_credential_for_referent(search_for_apply_loan_proof_request, 'attr1_referent')
    cred_for_predicate1 = await get_credential_for_referent(search_for_apply_loan_proof_request, 'predicate1_referent')
    cred_for_predicate2 = await get_credential_for_referent(search_for_apply_loan_proof_request, 'predicate2_referent')

    await anoncreds.prover_close_credentials_search_for_proof_req(search_for_apply_loan_proof_request)

    creds_for_apply_loan_proof = {cred_for_attr1['referent']: cred_for_attr1,
                                  cred_for_predicate1['referent']: cred_for_predicate1,
                                  cred_for_predicate2['referent']: cred_for_predicate2}

    schemas_json, cred_defs_json, revoc_states_json = \
        await prover_get_entities_from_ledger(pool_handle, alice_thrift_did, creds_for_apply_loan_proof, 'Alice')

    logger.info("\"Alice\" -> Create \"Loan-Application-Basic\" Proof")
    apply_loan_requested_creds_json = json.dumps({
        'self_attested_attributes': {},
        'requested_attributes': {
            'attr1_referent': {'cred_id': cred_for_attr1['referent'], 'revealed': True}
        },
        'requested_predicates': {
            'predicate1_referent': {'cred_id': cred_for_predicate1['referent']},
            'predicate2_referent': {'cred_id': cred_for_predicate2['referent']}
        }
    })
    alice_apply_loan_proof_json = \
        await anoncreds.prover_create_proof(alice_wallet[0], apply_loan_proof_request_json,
                                            apply_loan_requested_creds_json, alice_master_secret_id, schemas_json,
                                            cred_defs_json, revoc_states_json)

    logger.info("\"Alice\" -> Send \"Loan-Application-Basic\" Proof to Thrift")

    authdecrypted_alice_apply_loan_proof = json.loads(alice_apply_loan_proof_json)
    logger.info("\"Thrift\" -> Get Schemas, Credential Definitions and Revocation Registries from Ledger"
                " required for Proof verifying")

    schemas_json, cred_defs_json, revoc_defs_json, revoc_regs_json = \
        await verifier_get_entities_from_ledger(pool_handle, thrift_did,
                                                authdecrypted_alice_apply_loan_proof['identifiers'], 'Thrift')

    logger.info("\"Thrift\" -> Verify \"Loan-Application-Basic\" Proof from Alice")
    assert 'Permanent' == \
           authdecrypted_alice_apply_loan_proof['requested_proof']['revealed_attrs']['attr1_referent']['raw']

    assert await anoncreds.verifier_verify_proof(apply_loan_proof_request_json,
                                                 alice_apply_loan_proof_json,
                                                 schemas_json, cred_defs_json, revoc_defs_json, revoc_regs_json)

    logger.info("==============================")

    logger.info("==============================")
    logger.info("== Apply for the loan with Thrift - Transcript and Job-Certificate proving  ==")
    logger.info("------------------------------")

    logger.info("\"Thrift\" -> Create \"Loan-Application-KYC\" Proof Request")
    apply_loan_kyc_proof_request_json = json.dumps({
        'nonce': '123432421212',
        'name': 'Loan-Application-KYC',
        'version': '0.1',
        'requested_attributes': {
            'attr1_referent': {'name': 'first_name'},
            'attr2_referent': {'name': 'last_name'},
            'attr3_referent': {'name': 'ssn'}
        },
        'requested_predicates': {}
    })

    logger.info("\"Thrift\" -> Send \"Loan-Application-KYC\" Proof Request to Alice")

    logger.info("\"Alice\" -> Get credentials for \"Loan-Application-KYC\" Proof Request")

    search_for_apply_loan_kyc_proof_request = \
        await anoncreds.prover_search_credentials_for_proof_req(alice_wallet[0],
                                                                apply_loan_kyc_proof_request_json, None)

    cred_for_attr1 = await get_credential_for_referent(search_for_apply_loan_kyc_proof_request, 'attr1_referent')
    cred_for_attr2 = await get_credential_for_referent(search_for_apply_loan_kyc_proof_request, 'attr2_referent')
    cred_for_attr3 = await get_credential_for_referent(search_for_apply_loan_kyc_proof_request, 'attr3_referent')

    await anoncreds.prover_close_credentials_search_for_proof_req(search_for_apply_loan_kyc_proof_request)

    creds_for_apply_loan_kyc_proof = {cred_for_attr1['referent']: cred_for_attr1,
                                      cred_for_attr2['referent']: cred_for_attr2,
                                      cred_for_attr3['referent']: cred_for_attr3}

    schemas_json, cred_defs_json, revoc_states_json = \
        await prover_get_entities_from_ledger(pool_handle, alice_thrift_did, creds_for_apply_loan_kyc_proof, 'Alice')

    logger.info("\"Alice\" -> Create \"Loan-Application-KYC\" Proof")

    apply_loan_kyc_requested_creds_json = json.dumps({
        'self_attested_attributes': {},
        'requested_attributes': {
            'attr1_referent': {'cred_id': cred_for_attr1['referent'], 'revealed': True},
            'attr2_referent': {'cred_id': cred_for_attr2['referent'], 'revealed': True},
            'attr3_referent': {'cred_id': cred_for_attr3['referent'], 'revealed': True}
        },
        'requested_predicates': {}
    })

    alice_apply_loan_kyc_proof_json = \
        await anoncreds.prover_create_proof(alice_wallet[0], apply_loan_kyc_proof_request_json,
                                            apply_loan_kyc_requested_creds_json, alice_master_secret_id,
                                            schemas_json, cred_defs_json, revoc_states_json)

    logger.info("\"Alice\" -> Send \"Loan-Application-KYC\" Proof to Thrift")

    authdecrypted_alice_apply_loan_kyc_proof = json.loads(alice_apply_loan_kyc_proof_json)
    logger.info("\"Thrift\" -> Get Schemas, Credential Definitions and Revocation Registries from Ledger"
                " required for Proof verifying")

    schemas_json, cred_defs_json, revoc_defs_json, revoc_regs_json = \
        await verifier_get_entities_from_ledger(pool_handle, thrift_did,
                                                authdecrypted_alice_apply_loan_kyc_proof['identifiers'], 'Thrift')

    logger.info("\"Thrift\" -> Verify \"Loan-Application-KYC\" Proof from Alice")
    assert 'Alice' == \
           authdecrypted_alice_apply_loan_kyc_proof['requested_proof']['revealed_attrs']['attr1_referent']['raw']
    assert 'Garcia' == \
           authdecrypted_alice_apply_loan_kyc_proof['requested_proof']['revealed_attrs']['attr2_referent']['raw']
    assert '123-45-6789' == \
           authdecrypted_alice_apply_loan_kyc_proof['requested_proof']['revealed_attrs']['attr3_referent']['raw']

    assert await anoncreds.verifier_verify_proof(apply_loan_kyc_proof_request_json,
                                                 alice_apply_loan_kyc_proof_json,
                                                 schemas_json, cred_defs_json, revoc_defs_json, revoc_regs_json)

    '''
    logger.info("Remove gov, faber, acme and thrift agents")
    
    event_send(agency,"agency","DELETE",{"name":"gov"    })
    event_send(agency,"agency","DELETE",{"name":"faber"  })
    event_send(agency,"agency","DELETE",{"name":"acme"   })
    event_send(agency,"agency","DELETE",{"name":"thrift" })

    logger.info("Getting started -> done")

def event_send(eci,domain,type,attrs):
    return requests.post(_host+"/sky/event/"+eci+"/none/"+domain+"/"+type,params=attrs)
if __name__ == '__main__':
    loop = asyncio.get_event_loop()
    loop.run_until_complete(run())
    time.sleep(1)  # FIXME waiting for libindy thread complete
